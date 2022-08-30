resource "hcloud_network" "kubernetes" {
  ip_range = local.network_cidr_ipv4
  name     = "kubernetes"
}

resource "hcloud_network_subnet" "kubernetes" {
  network_id   = hcloud_network.kubernetes.id
  ip_range     = local.cluster_cidr_ipv4
  type         = "cloud"
  network_zone = "eu-central"
}

resource "hcloud_placement_group" "homelab" {
  name = "homelab"
  type = "spread"
}

resource "hcloud_firewall" "homelab" {
  name = "homelab"

  dynamic "rule" {
    for_each = local.firewall_rules
    content {
      direction       = rule.value.direction
      protocol        = rule.value.protocol
      port            = lookup(rule.value, "port", null)
      destination_ips = lookup(rule.value, "destination_ips", [])
      source_ips      = lookup(rule.value, "source_ips", [])
    }
  }
}
