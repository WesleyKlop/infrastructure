
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
  server_type = "cx21"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  ssh_keys = [
    var.management_ssh_key_id,
    local.ssh_key_id
  ]
  user_data          = data.cloudinit_config.base-config.rendered
  placement_group_id = hcloud_placement_group.homelab.id
  firewall_ids       = []

  network {
    network_id = hcloud_network.kubernetes.id
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  lifecycle {
    ignore_changes = [
      user_data,
      location,
      ssh_keys,
      network
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
        --pod-network-cidr ${local.pod_cidr_ipv4} \
        --apiserver-advertise-address 0.0.0.0 \
        --apiserver-cert-extra-sans ${self.ipv4_address},${self.network.*.ip[0]} \
        --control-plane-endpoint ${self.network.*.ip[0]} \
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
      "kubectl apply -f '/root/bootstrap/secrets.yaml'",
      "kubectl apply -f 'https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml'",
      "kubectl apply -f 'https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/latest/download/ccm.yaml'",
      "kubectl apply -f 'https://raw.githubusercontent.com/hetznercloud/csi-driver/v1.6.0/deploy/kubernetes/hcloud-csi.yml'",
      "kubectl wait --for=condition=Ready -l kubernetes.io/hostname=${self.name} nodes"
    ]
  }
}

data "external" "kubeadm_join" {
  program = ["${path.module}/scripts/kubeadm-join.sh"]

  query = {
    host         = hcloud_server.control-plane.ipv4_address
    sshkey       = local.ssh_key_private
    hostinternal = hcloud_server.control-plane.network.*.ip[0]
  }

  depends_on = [hcloud_server.control-plane]
}

resource "hcloud_server" "worker" {
  count       = 2
  name        = "worker-${count.index}"
  server_type = "cx11"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  ssh_keys = [
    var.management_ssh_key_id,
    local.ssh_key_id
  ]
  user_data          = data.cloudinit_config.base-config.rendered
  placement_group_id = hcloud_placement_group.homelab.id
  firewall_ids       = []

  network {
    network_id = hcloud_network.kubernetes.id
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  lifecycle {
    ignore_changes = [
      user_data,
      location,
      ssh_keys,
      network
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
      "${data.external.kubeadm_join.result.command}",
    ]
  }
}
