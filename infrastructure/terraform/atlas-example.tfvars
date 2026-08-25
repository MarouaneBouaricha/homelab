proxmox_endpoint      = "https://IP_ADDRESS:8006/api2/json"
proxmox_username      = "user@pve"
proxmox_password      = "yoursecretpassword"

cluster_name          = "atlas-homelab"
prefix                = "talos"

proxmox_node_name     = "server1"
proxmox_network_bridge = "vmbr0"

talos_version         = "v1.11.3"
talos_qemu_iscsi_hash = "077514df2c1b6436460bc60faabc976687b16193b8a1290fda4366c69024fec2"
talos_img_hash        = "c9cf59861cdc23140374d3f1a8b6054a3bfd2dcbabf115e352b9523d8c9a8395"

kubernetes_version    = "1.32.0"

cluster_node_network          = "192.168.1.0/24"
cluster_node_network_gateway  = "192.168.1.1"
cluster_vip                   = "192.168.1.50"
cluster_node_network_first_controller_hostnum = 60
cluster_node_network_first_worker_hostnum      = 70

load_balancer_ip_range = {
  first = 80
  last  = 85
}

controller_config = {
  count  = 1
  cpu    = 2
  memory = 6144

  os_disk = {
    size      = 20
    datastore = "vms-store"
  }
}

worker_config = {
  count  = 2
  cpu    = 2
  memory = 4096

  os_disk = {
    size      = 20
    datastore = "vms-store"
  }

  longhorn_disk = {
    size      = 40
    datastore = "vms-store"
  }
}
