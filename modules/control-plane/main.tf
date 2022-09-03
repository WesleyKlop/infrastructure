module "control_plane" {
  source = "../node"

  providers = {
    hcloud = hcloud,
  }

  name               = var.name
  firewall_ids       = var.firewall_ids
  network_id         = var.network_id
  placement_group_id = var.placement_group_id
  server_type        = var.server_type
  authorized_keys    = var.authorized_keys
  user_data = [
    templatefile("${path.module}/templates/user-data.yaml", {
      api_token  = var.cluster_api_token
      network_id = var.network_id
    })
  ]
}

resource "null_resource" "init" {
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = local.public_ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "set -eux",
      "cloud-init status --wait > /dev/null",
      <<-BASH
      kubeadm init \
        --ignore-preflight-errors NumCPU \
        --pod-network-cidr ${var.pod_ipv4_cidr} \
        --apiserver-advertise-address 0.0.0.0 \
        --apiserver-cert-extra-sans ${local.public_ipv4_address},${local.private_ipv4_address} \
        --control-plane-endpoint ${local.private_ipv4_address} \
        --upload-certs \
        --skip-token-print
      BASH
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "set -eux",
      "mkdir ~/.kube",
      "cp /etc/kubernetes/admin.conf ~/.kube/config",
      "kubectl apply --server-side -f '/root/bootstrap/secrets.yaml'",
      "kubectl apply --server-side -k 'github.com/wesleyklop/infrastructure//bootstrap/flannel?ref=javelin'",
      "kubectl apply --server-side -k 'github.com/wesleyklop/infrastructure//bootstrap/hetzner?ref=javelin'",
      "kubectl wait --for=condition=Ready -l kubernetes.io/hostname=${local.name} nodes",
      # Required for traefik, only on control-plane
      "mkdir /opt/traefik",
      "chown 65532:65532 /opt/traefik",
      "chmod 700 /opt/traefik"
    ]
  }

  depends_on = [
    module.control_plane
  ]
}

data "external" "kubeadm_join" {
  program = ["${path.module}/scripts/kubeadm-join.sh"]

  query = {
    host   = local.public_ipv4_address
    sshkey = var.ssh_private_key
  }

  depends_on = [null_resource.init]
}
