locals {
  ssh_key_id      = hcloud_ssh_key.tf-ssh-key.id
  ssh_key_private = tls_private_key.ssh-key.private_key_openssh
}

locals {
  firewall_enabled = false
  # The main network cidr that all subnets will be created upon
  network_ipv4_cidr = "10.0.0.0/8"

  # The following IPs are important to be whitelisted because they communicate with Hetzner services and enable the CCM and CSI to work properly.
  # Source https://github.com/hetznercloud/csi-driver/issues/204#issuecomment-848625566
  hetzner_metadata_service_ipv4 = "169.254.169.254/32"
  hetzner_cloud_api_ipv4        = "213.239.246.1/32"

  # CIDR Ranges for cluster networking
  pod_ipv4_cidr     = "10.244.0.0/16"
  cluster_ipv4_cidr = "10.42.0.0/16"

  whitelisted_ips = [
    local.network_ipv4_cidr,
    local.hetzner_metadata_service_ipv4,
    local.hetzner_cloud_api_ipv4,
    "127.0.0.1/32",
  ]
}
