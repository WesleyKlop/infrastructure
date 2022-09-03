# Bootstraps the cluster

resource "null_resource" "argocd" {
  triggers = {
    "generation" = 0
  }

  connection {
    user        = "root"
    host        = hcloud_server.control-plane.ipv4_address
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
