
data "cloudinit_config" "base-config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.yaml"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init-base.yaml", {
      api_token  = var.cluster_api_token
      network_id = hcloud_network.kubernetes.id
    })
  }
}

resource "hcloud_server" "control-plane" {
  name        = "control-plane"
  server_type = "cx11"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  ssh_keys = [
    var.management_ssh_key_id,
    local.ssh_key_id
  ]
  user_data = data.cloudinit_config.base-config.rendered

  network {
    network_id = hcloud_network.kubernetes.id
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  lifecycle {
    ignore_changes = [
      # user_data,
      location,
      ssh_keys
    ]
  }

  connection {
    user        = "root"
    host        = self.ipv4_address
    private_key = local.ssh_key_private
  }

  provisioner "remote-exec" {
    inline = [
      "set -eux",
      "cloud-init status --wait > /dev/null",
      <<-BASH
      kubeadm init \
        --ignore-preflight-errors NumCPU \
        --pod-network-cidr 10.244.0.0/16 \
        --apiserver-cert-extra-sans 10.0.0.1 \
        --upload-certs \
        --skip-token-print
      BASH
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "set -eux",
      "export KUBECONFIG=/etc/kubernetes/admin.conf",
      "kubectl apply -f '/root/bootstrap/secrets.yaml'",
      "kubectl apply -f 'https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml'",
      "kubectl apply -f 'https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/latest/download/ccm.yaml'",
      "kubectl wait --for=condition=Ready -l kubernetes.io/hostname=control-plane nodes"
    ]
  }
}

data "external" "kubeadm_join" {
  program = ["${path.module}/scripts/kubeadm-join.sh"]

  query = {
    host = hcloud_server.control-plane.ipv4_address
  }

  depends_on = [hcloud_server.control-plane]
}


resource "hcloud_server" "worker-1" {
  name        = "worker-1"
  server_type = "cx11"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  ssh_keys = [
    var.management_ssh_key_id,
    local.ssh_key_id
  ]
  user_data = data.cloudinit_config.base-config.rendered

  network {
    network_id = hcloud_network.kubernetes.id
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  lifecycle {
    ignore_changes = [
      # user_data,
      location,
      ssh_keys
    ]
  }

  connection {
    user        = "root"
    host        = self.ipv4_address
    private_key = local.ssh_key_private
  }

  provisioner "remote-exec" {
    inline = [
      "set -eux",
      "cloud-init status --wait > /dev/null",
      "${data.external.kubeadm_join.result}",
    ]
  }
}
