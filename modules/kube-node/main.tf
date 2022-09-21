resource "null_resource" "set-kube-version" {
  triggers = {
    "version" = var.version
  }

  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = var.node_address
  }

  provisioner "remote-exec" {
    inline = [
      "set -euo pipefail",
      "apt update",

      "apt-mark unhold kubeadm",
      "apt install -y kubeadm='${var.version}-00'",
      "apt-mark hold kubeadm",

      "kubeadm upgrade apply v${var.version}",

      "apt-mark unhold kubelet kubectl",
      "apt install -y kubectl='${var.version}-00' kubectl='${var.version}-00'",
      "apt-mark hold kubelet kubectl",

      "apt-mark unhold containerd.io",
      "apt upgrade -y containerd.io",
      "apt-mark hold containerd.io"
    ]
  }
}
