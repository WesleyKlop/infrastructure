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

  argocd_url       = "https://argocd-javelin.wesl.io"
  repo_name        = "infrastructure"
  repo_description = "Server infrastructure in Kubernetes"
  control_plane_ip = module.control-plane.public_ipv4_address
  ssh_private_key  = local.ssh_private_key

  op_credentials = var.op_credentials
  op_token       = var.op_token

  gha_tf_api_token = var.gha_tf_api_token

  depends_on = [
    module.control-plane
  ]
}
