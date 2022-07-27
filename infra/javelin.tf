variable "hcloud_token" {
  sensitive = true
}
variable "cluster_api_token" {
  sensitive = true
}
provider "hcloud" {
  token = var.hcloud_token
}

resource "random_password" "cluster_token_start" {
  length = 6
  upper = false
  special = false
}
resource "random_password" "cluster_token_end" {
  length = 16
  upper = false
  special = false
}


locals {
  cluster_token = sensitive("${random_password.cluster_token_start.result}.${random_password.cluster_token_end.result}")
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

resource "hcloud_floating_ip" "kubernetes" {
  name          = "load-balancer"
  home_location = "nbg1"
  type          = "ipv4"
}

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
    ipv6_enabled = false
  }
  ssh_keys = ["wesley19097@gmail.com"]
  depends_on = [
    hcloud_network_subnet.kubernetes
  ]
  user_data = templatefile("templates/cloud-init-control-plane.yaml", {
    api_token = var.cluster_api_token
    network_id = hcloud_network.kubernetes.id
    cluster_token = local.cluster_token
  })
}

# resource "hcloud_server" "worker-1" {
#   name        = "worker-1"
#   server_type = "cx11"
#   image       = "ubuntu-20.04"
#   location    = "nbg1"
#   network {
#     network_id = hcloud_network.kubernetes.id
#   }
#   public_net {
#     ipv4_enabled = true
#     ipv6_enabled = false
#   }
#   ssh_keys = ["wesley19097@gmail.com"]
#   depends_on = [
#     hcloud_network_subnet.kubernetes,
#     hcloud_floating_ip.kubernetes
#   ]
#   user_data = templatefile("templates/cloud-init-worker.yaml", {
#     floating_ip = hcloud_floating_ip.kubernetes.ip_address
#   })
# }

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
