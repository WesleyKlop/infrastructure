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

resource "hcloud_firewall_attachment" "homelab" {
  firewall_id = hcloud_firewall.homelab.id
  server_ids  = concat(hcloud_server.control-plane.*.id, hcloud_server.worker.*.id)
}
