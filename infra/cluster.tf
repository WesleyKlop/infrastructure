# Bootstraps the cluster

resource "null_resource" "argocd" {
  triggers = {
    "generation" = 1
  }

  provisioner "remote-exec" {
    inline = [
      "set -eu",
      "rm -rf bootstrap/argo-cd",
    ]
  }

  connection {
    user        = "root"
    host        = hcloud_server.control-plane.ipv4_address
    private_key = local.ssh_key_private
  }

  provisioner "file" {
    source      = "./bootstrap/argo-cd"
    destination = "/root/bootstrap/argo-cd"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/argocd-homelab-repository.yaml", {
      ssh_key = var.argocd_ssh_key
    })
    destination = "/root/bootstrap/argo-cd/resources/argocd-homelab-repository.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "set -eu",
      "kubectl apply --server-side --force-conflicts -k bootstrap/argo-cd",
    ]
  }
}
