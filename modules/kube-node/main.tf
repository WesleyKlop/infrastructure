resource "null_resource" "set-kube-version" {
  triggers = {
    "version" = var.kube_version
  }

  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = var.node_address
  }

  provisioner "remote-exec" {
    inline = [
      <<-BASH
      set -euo pipefail

      apt update

      CURRENT_VERSION="$(dpkg -s kubeadm | grep '^Version:' | cut -d' ' -f2)"
      LONG_VERSION="${var.kube_version}-00"
      LATEST_VERSION="$(apt info kubeadm | grep '^Version:' | cut -d' ' -f2)"

      if [ "$CURRENT_VERSION" == "$LONG_VERSION" ]; then
        echo "Already up to date, so not doing any updates."
        if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
          >&2 echo "But $CURRENT_VERSION is the latest version so you might want to upgrade..."
        fi
        exit 0
      fi

      apt-mark unhold kubeadm
      apt install -y kubeadm="$LONG_VERSION"
      apt-mark hold kubeadm

      kubeadm upgrade apply "v${var.kube_version}"

      apt-mark unhold kubelet kubectl
      apt install -y kubectl="$LONG_VERSION" kubectl="$LONG_VERSION"
      apt-mark hold kubelet kubectl

      apt-mark unhold containerd.io
      apt upgrade -y containerd.io
      apt-mark hold containerd.io
      BASH
    ]
  }
}
