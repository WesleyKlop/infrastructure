locals {
  ssh_key_id      = hcloud_ssh_key.tf-ssh-key.id
  ssh_key_private = tls_private_key.ssh-key.private_key_openssh
}

locals {
  # The main network cidr that all subnets will be created upon
  network_cidr_ipv4 = "10.0.0.0/8"

  # The following IPs are important to be whitelisted because they communicate with Hetzner services and enable the CCM and CSI to work properly.
  # Source https://github.com/hetznercloud/csi-driver/issues/204#issuecomment-848625566
  hetzner_metadata_service_ipv4 = "169.254.169.254/32"
  hetzner_cloud_api_ipv4        = "213.239.246.1/32"

  # CIDR Ranges for cluster networking
  pod_cidr_ipv4     = "10.244.0.0/16"
  cluster_cidr_ipv4 = "10.98.0.0/16"

  whitelisted_ips = [
    local.network_cidr_ipv4,
    local.hetzner_metadata_service_ipv4,
    local.hetzner_cloud_api_ipv4,
    "127.0.0.1/32",
  ]

  firewall_rules = concat([
    # Allowing internal cluster traffic and Hetzner metadata service and cloud API IPs
    {
      direction  = "in"
      protocol   = "tcp"
      port       = "any"
      source_ips = local.whitelisted_ips
    },
    {
      direction  = "in"
      protocol   = "udp"
      port       = "any"
      source_ips = local.whitelisted_ips
    },
    {
      direction  = "in"
      protocol   = "icmp"
      source_ips = local.whitelisted_ips
    },

    # Allow all traffic to the kube api server
    {
      direction = "in"
      protocol  = "tcp"
      port      = "6443"
      source_ips = [
        "0.0.0.0/0"
      ]
    },

    # Allow all traffic to the ssh port
    {
      direction = "in"
      protocol  = "tcp"
      port      = "22"
      source_ips = [
        "0.0.0.0/0"
      ]
    },

    # Allow ping on ipv4
    {
      direction = "in"
      protocol  = "icmp"
      source_ips = [
        "0.0.0.0/0"
      ]
    },

    # Allow basic out traffic
    # ICMP to ping outside services
    {
      direction = "out"
      protocol  = "icmp"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },

    # DNS
    {
      direction = "out"
      protocol  = "tcp"
      port      = "53"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },
    {
      direction = "out"
      protocol  = "udp"
      port      = "53"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },

    # GPG Keyservers
    {
      direction = "out"
      protocol  = "tcp"
      port      = "11371"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },

    # HTTP(s)
    {
      direction = "out"
      protocol  = "tcp"
      port      = "80"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },
    {
      direction = "out"
      protocol  = "tcp"
      port      = "443"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },

    #NTP
    {
      direction = "out"
      protocol  = "udp"
      port      = "123"
      destination_ips = [
        "0.0.0.0/0"
      ]
    }

    ], [
    # Argo CD Access to repositories
    {
      direction = "out"
      protocol  = "tcp"
      port      = "22"
      destination_ips = [
        "0.0.0.0/0"
      ]
    },
  ])
}
