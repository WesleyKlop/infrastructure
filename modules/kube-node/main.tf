# NOTE TO SELF
# This does not really work
# Terraform will try to do all these upgrade parallel instead of sequential, taking down the entire cluster
# Random idea:
# 1a. Configure ssh config file, specifying to ProxyJump through the control-plane
# 1b. Configure ssh agent???? Combined with ProxyJump and AgentForwarding might be nice.
# 1c. Would also allow to lock down worker nodes further, like not exposing them to the internet
# 1d. And we could proxy kube-api and ssh through the LB? Then we can also lock down the control plane node.
#     But dont know how that would work with > 1 control planes.
#  2. Upgrade the control-plane node first
# 3a. Iterate through all worker nodes from the control-plane node
# 3b.   First draining the node
# 3c.   Then upgrading kubeadm/kubectl/kubelet
# 3d.   Then upgrading containerd.io
# 3e.   Then reloading kubelet
# 3f.   Then uncordoning the node
#  4. Profit
# So basically we cannot manage this on a node level but only on a cluster level
# But can be reused for both cloud- and homelab! :D

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
      #!/usr/bin/env bash
      set -euxo pipefail

      apt update -qq

      CURRENT_VERSION="$(dpkg -s kubeadm | grep '^Version:' | cut -d' ' -f2)"
      LONG_VERSION="${var.kube_version}-00"
      LATEST_VERSION="$(apt info kubeadm | grep '^Version:' | cut -d' ' -f2)"

      if [ "$CURRENT_VERSION" == "$LONG_VERSION" ]; then
        echo "Already up to date, so not doing any updates."
        if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
          >&2 echo "But $LATEST_VERSION is the latest version so you might want to upgrade..."
        fi
        exit 0
      fi

      apt-mark unhold kubeadm
      apt install -y -qq kubeadm="$LONG_VERSION"
      apt-mark hold kubeadm

      if [ "${var.is_control_plane}" == "true" ]; then
        kubeadm upgrade apply "v${var.kube_version}"
      else
        kubeadm upgrade node
      fi

      apt-mark unhold kubelet kubectl
      apt install -y kubectl="$LONG_VERSION" kubectl="$LONG_VERSION"
      apt-mark hold kubelet kubectl

      apt-mark unhold containerd.io
      apt upgrade -y containerd.io
      apt-mark hold containerd.io

      systemctl daemon-reload
      systemctl restart kubelet
      BASH
    ]
  }
}
