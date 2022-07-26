variable "hcloud_token" {}
provider "hcloud" {
  token = var.hcloud_token
}

# Networking
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

resource "hcloud_primary_ip" "control-plane" {
  name          = "control-plane"
  type          = "ipv4"
  datacenter    = "nbg1-dc3"
  assignee_type = "server"
  auto_delete   = true
}

resource "hcloud_floating_ip" "kubernetes" {
  home_location = "nbg1"
  type          = "ipv4"

}

# Servers
resource "hcloud_server" "control-plane" {
  name        = "control-plane"
  server_type = "cx11"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  network {
    network_id = hcloud_network.kubernetes.id
  }
  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.control-plane.id
    ipv6_enabled = false
  }
  ssh_keys = ["wesley19097@gmail.com"]
  depends_on = [
    hcloud_network_subnet.kubernetes
  ]
  user_data = file("cloud-init-control-plane.yaml")
}

resource "hcloud_server" "worker-1" {
  name        = "worker-1"
  server_type = "cx11"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  network {
    network_id = hcloud_network.kubernetes.id
  }
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  ssh_keys = ["wesley19097@gmail.com"]
  depends_on = [
    hcloud_network_subnet.kubernetes,
    hcloud_floating_ip.kubernetes
  ]
  user_data = replace(file("cloud-init-worker.yaml"), "%floating-ip%", hcloud_floating_ip.kubernetes.ip_address)
}

# resource "hcloud_server" "worker-2" {
#   name        = "worker-2"
#   server_type = "cx11"
#   image       = "ubuntu-20.04"
#   location    = "nbg1"
#   network {
#     network_id = hcloud_network.kubernetes.id
#   }
#   ssh_keys = ["wesley19097@gmail.com"]
#   depends_on = [
#     hcloud_network_subnet.kubernetes
#   ]
#   public_net {
#     ipv4_enabled = true
#     ipv6_enabled = false
#   }
# }
