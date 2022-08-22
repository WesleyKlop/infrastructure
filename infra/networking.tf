
resource "hcloud_network" "kubernetes" {
  ip_range = "10.98.0.0/16"
  name     = "kubernetes"
}

resource "hcloud_network_subnet" "kubernetes" {
  network_id   = hcloud_network.kubernetes.id
  ip_range     = "10.98.0.0/16"
  type         = "cloud"
  network_zone = "eu-central"
}

resource "hcloud_placement_group" "homelab" {
  name = "homelab"
  type = "spread"
}
