# Bootstraps the cluster

resource "null_resource" "argocd" {
  triggers = {
    "generation" = 3
  }

  provisioner "remote-exec" {
    inline = [
      "set -eu",
      "rm -rf /root/bootstrap",
    ]
  }

  connection {
    user        = "root"
    host        = hcloud_server.control-plane.ipv4_address
    private_key = local.ssh_key_private
  }

  provisioner "file" {
    source      = "./bootstrap"
    destination = "/root/bootstrap"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/argocd-homelab-repository.yaml", {
      ssh_key = var.argocd_ssh_key
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
      "set -eu",
      "kubectl apply --server-side --force-conflicts -k bootstrap"
    ]
  }
}
