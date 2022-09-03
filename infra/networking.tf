resource "hcloud_network" "kubernetes" {
  ip_range = local.network_ipv4_cidr
  name     = "kubernetes"
}

resource "hcloud_network_subnet" "kubernetes" {
  network_id   = hcloud_network.kubernetes.id
  ip_range     = local.cluster_ipv4_cidr
  type         = "cloud"
  network_zone = "eu-central"
}

resource "hcloud_placement_group" "homelab" {
  name = "homelab"
  type = "spread"
}

# hcloud_firewall.homelab:
resource "hcloud_firewall" "homelab" {
  name = "homelab"

  # Allowing internal cluster traffic and Hetzner metadata service and cloud API IPs
  rule {
    direction  = "in"
    port       = "any"
    protocol   = "tcp"
    source_ips = local.whitelisted_ips
  }
  rule {
    direction  = "in"
    port       = "any"
    protocol   = "udp"
    source_ips = local.whitelisted_ips
  }
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = local.whitelisted_ips
  }

  rule {
    description = "Allow all traffic to the kube api server"
    direction   = "in"
    port        = "6443"
    protocol    = "tcp"
    source_ips = [
      "0.0.0.0/0",
    ]
  }

  rule {
    description = "Allow all traffic towards ssh"
    direction   = "in"
    port        = "22"
    protocol    = "tcp"
    source_ips = [
      "0.0.0.0/0",
    ]
  }

  rule {
    description = "Allow ping on ipv4"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      "0.0.0.0/0",
    ]
  }
  rule {
    description = "ICMP to ping outside services"
    direction   = "out"
    protocol    = "icmp"
    destination_ips = [
      "0.0.0.0/0",
    ]
  }

  rule {
    description = "DNS"
    direction   = "out"
    port        = "53"
    protocol    = "tcp"
    destination_ips = [
      "0.0.0.0/0",
    ]
  }
  rule {
    description = "DNS"
    direction   = "out"
    port        = "53"
    protocol    = "udp"
    destination_ips = [
      "0.0.0.0/0",
    ]
  }

  rule {
    description = "NTP"
    direction   = "out"
    port        = "123"
    protocol    = "udp"
    destination_ips = [
      "0.0.0.0/0",
    ]
  }

  rule {
    description = "GPG Keyservers"
    direction   = "out"
    port        = "11371"
    protocol    = "tcp"
    destination_ips = [
      "0.0.0.0/0",
    ]
  }

  rule {
    description = "HTTP"
    direction   = "out"
    port        = "80"
    protocol    = "tcp"
    destination_ips = [
      "0.0.0.0/0",
    ]
  }
  rule {
    description = "HTTPS"
    direction   = "out"
    port        = "443"
    protocol    = "tcp"
    destination_ips = [
      "0.0.0.0/0",
    ]
  }

  rule {
    description = "Argo CD clone git repositories over ssh"
    direction   = "out"
    port        = "22"
    protocol    = "tcp"
    destination_ips = [
      "0.0.0.0/0",
    ]
  }
}

# resource "hcloud_firewall_attachment" "homelab" {
#   firewall_id = hcloud_firewall.homelab.id
#   server_ids  = concat(hcloud_server.control-plane.*.id, hcloud_server.worker.*.id)
# }
