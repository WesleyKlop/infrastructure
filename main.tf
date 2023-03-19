resource "tls_private_key" "ssh-key" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "tf-ssh-key" {
  name       = "tf-ssh-key"
  public_key = tls_private_key.ssh-key.public_key_openssh
}

module "control-plane" {
  source = "./modules/control-plane"

  providers = {
    hcloud = hcloud
  }

  cluster_api_token  = var.cluster_api_token
  firewall_ids       = local.firewall_enabled ? [hcloud_firewall.cloudlab.id] : []
  placement_group_id = hcloud_placement_group.cloudlab.id
  name               = "control-plane"
  server_type        = "cx21"
  network_id         = hcloud_network.cloudlab.id
  pod_ipv4_cidr      = local.pod_ipv4_cidr
  authorized_keys    = [var.management_ssh_key_id, local.ssh_key_id]
  ssh_private_key    = local.ssh_private_key
}


module "worker" {
  source = "./modules/worker"

  providers = {
    hcloud = hcloud
  }

  count              = 3
  name               = "worker-${count.index}"
  server_type        = "cx21"
  firewall_ids       = local.firewall_enabled ? [hcloud_firewall.cloudlab.id] : []
  placement_group_id = hcloud_placement_group.cloudlab.id
  network_id         = hcloud_network.cloudlab.id
  authorized_keys    = [var.management_ssh_key_id, local.ssh_key_id]
  ssh_private_key    = local.ssh_private_key
  join_command       = module.control-plane.kubeadm_join_command

  depends_on = [
    module.control-plane
  ]
}

module "gitops" {
  source = "./modules/gitops"

  providers = {
    github = github
  }

  argocd_url       = "https://argocd.wesley.io"
  repo_name        = "infrastructure"
  repo_description = "My Homelab and Cloudlab"
  control_plane_ip = module.control-plane.public_ipv4_address
  ssh_private_key  = local.ssh_private_key

  op_credentials = var.op_credentials
  op_token       = var.op_token

  gha_tf_api_token = var.gha_tf_api_token

  depends_on = [
    module.control-plane
  ]
}

module "cloudlab-cluster" {
  source = "./modules/cluster"

  control_plane = module.control-plane.public_ipv4_address
  workers = {
    for worker in module.worker : (worker.name) => worker.private_ipv4_address
  }

  ssh_private_key = local.ssh_private_key
  kube_version    = "1.25.5"

  depends_on = [
    module.control-plane,
    module.worker[0]
  ]
}

module "homelab-cluster" {
  source = "./modules/cluster"

  control_plane = var.homelab_ipv4_address
  workers       = {}

  ssh_private_key = local.ssh_private_key
  kube_version    = "1.25.8"
}
