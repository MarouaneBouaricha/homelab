module "proxmox_talos" {
  source = "./modules/proxmox_talos"

  proxmox_node_name      = var.proxmox_node_name
  proxmox_admin_endpoint = var.proxmox_admin_endpoint
  proxmox_username       = var.proxmox_username
  proxmox_password       = var.proxmox_password
  proxmox_insecure       = var.proxmox_insecure
  datastore_name         = var.datastore_name

  proxmox_vms_default_gateway = var.proxmox_vms_default_gateway
  proxmox_vms_talos           = var.proxmox_vms_talos

  talos_cluster_name = "k8s-dev"
}
