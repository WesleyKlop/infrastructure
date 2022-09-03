module "control-plane" {
  source = "./modules/control-plane"

  providers = {
    hcloud = hcloud
  }

  cluster_api_token  = var.cluster_api_token
  firewall_ids       = local.firewall_enabled ? [hcloud_firewall.homelab.id] : []
  placement_group_id = hcloud_placement_group.homelab.id
  name               = "control-plane"
  server_type        = "cx21"
  network_id         = hcloud_network.kubernetes.id
  pod_ipv4_cidr      = local.pod_ipv4_cidr
  authorized_keys    = [var.management_ssh_key_id, local.ssh_key_id]
  ssh_private_key    = local.ssh_key_private
}


module "worker" {
  source = "./modules/worker"

  providers = {
    hcloud = hcloud
  }

  count              = 2
  name               = "worker-${count.index}"
  server_type        = "cx11"
  firewall_ids       = local.firewall_enabled ? [hcloud_firewall.homelab.id] : []
  placement_group_id = hcloud_placement_group.homelab.id
  network_id         = hcloud_network.kubernetes.id
  authorized_keys    = [var.management_ssh_key_id, local.ssh_key_id]
  ssh_private_key    = local.ssh_key_private
  join_command       = module.control-plane.kubeadm_join_command

  depends_on = [
    module.control-plane
  ]
}

resource "null_resource" "argocd" {
  triggers = {
    "generation" = 0
  }

  connection {
    user        = "root"
    host        = module.control-plane.public_ipv4_address
    private_key = local.ssh_key_private
  }

  provisioner "remote-exec" {
    inline = [
      "set -eu",
      "rm -rf /root/bootstrap",
    ]
  }

  provisioner "file" {
    source      = "./bootstrap"
    destination = "/root/bootstrap"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/argocd-homelab-repository.yaml", {
      ssh_key = tls_private_key.deploy-key.private_key_openssh
    })
    destination = "/root/bootstrap/resources/argocd-homelab-repository.yaml"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/bootstrap-store.yaml", {
      op_token       = var.op_token
      op_credentials = var.op_credentials
    })
    destination = "/root/bootstrap/resources/bootstrap-store.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      <<-BASH
      kubectl apply --server-side -k bootstrap
      if [ $? -eq 0 ]; then
        exit 0
      else
        sleep 10
        kubectl apply --server-side -k bootstrap
        exit $?
      fi
      BASH
    ]
  }
}
