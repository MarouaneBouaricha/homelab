terraform {
  required_providers {
    proxmox = {
      # https://registry.terraform.io/providers/bpg/proxmox/latest/docs
      source = "bpg/proxmox"
      version = "0.74.1"
    }
    talos = {
      # https://registry.terraform.io/providers/siderolabs/talos/latest/docs
      source = "siderolabs/talos"
      version = "0.7.1"
    }
  }
}