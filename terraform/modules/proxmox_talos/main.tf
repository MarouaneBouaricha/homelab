provider "proxmox" {
  endpoint = var.proxmox_admin_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox_insecure
}

locals {
  controller_vm_ips = [
    for key, node in var.proxmox_vms_talos : replace(node.ip, "/24", "")
    if node.controller == true
  ]
  worker_vm_ips = [
    for key, node in var.proxmox_vms_talos : replace(node.ip, "/24", "")
    if node.controller != true
  ]
  talos_machine_config_patches = var.talos_remove_cni ? [
    yamlencode({
      cluster = {
        network = {
          cni = {
            name = "none"
          }
        }
      }
    })
  ] : []
}

# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm
resource "proxmox_virtual_environment_vm" "talos" {
  for_each        = var.proxmox_vms_talos

  on_boot         = true
  stop_on_destroy = true
  vm_id           = each.value.id
  name            = "${var.talos_cluster_name}-${each.key}"
  node_name       = var.proxmox_node_name
  tags            = sort(["terraform", var.talos_cluster_name])
  bios            = "ovmf"
  machine         = "q35"
  scsi_hardware   = "virtio-scsi-single"
  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }
  cpu {
    type  = "host"
    cores = 3
  }
  memory {
    dedicated = 3 * 1024
  }
  network_device {
    bridge = "vmbr0"
  }
  efi_disk {
    datastore_id = var.datastore_name
    file_format  = "raw"
    type         = "4m"
  }
  disk {
    datastore_id = var.datastore_name
    interface    = "scsi0"
    iothread     = true
    ssd          = true
    discard      = "on"
    size         = 50
    file_format  = "raw"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
  }
  agent {
    enabled = true
    trim    = true
  }
  initialization {
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.proxmox_vms_default_gateway
      }
    }
  }
}

# https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_secrets
resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.controller_vm_ips
}

data "talos_machine_configuration" "controller" {
  cluster_name     = var.talos_cluster_name
  cluster_endpoint = "https://${local.controller_vm_ips[0]}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  examples         = false
  docs             = false
  config_patches   = local.talos_machine_config_patches
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.talos_cluster_name
  cluster_endpoint = "https://${local.controller_vm_ips[0]}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  examples         = false
  docs             = false
  config_patches   = local.talos_machine_config_patches
}

# https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply
resource "talos_machine_configuration_apply" "controller" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos ]
  for_each                    = toset(local.controller_vm_ips)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller.machine_configuration
  node                        = each.value
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos ]
  for_each                    = toset(local.worker_vm_ips)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value
}

// see https://registry.terraform.io/providers/siderolabs/talos/0.6.1/docs/resources/machine_bootstrap
resource "talos_machine_bootstrap" "this" {
  depends_on           = [
    talos_machine_configuration_apply.controller,
    talos_machine_configuration_apply.worker
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controller_vm_ips[0]
}

data "talos_cluster_health" "this" {
  depends_on = [ talos_machine_bootstrap.this ]

  client_configuration = data.talos_client_configuration.this.client_configuration
  control_plane_nodes  = local.controller_vm_ips
  worker_nodes         = local.worker_vm_ips
  endpoints            = data.talos_client_configuration.this.endpoints
  timeouts = {
    read = "10m"
  }
}

# Introducing explicit dependency on talos_cluster_health so that output is available only after 
# the k8s cluter is up and running. Otherwise `kubernetes` and `kubectl` resources are timimg out
# trying to connect to the cluster that is is still booting up.
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [ data.talos_cluster_health.this ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controller_vm_ips[0]
}