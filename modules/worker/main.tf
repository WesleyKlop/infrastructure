module "worker" {
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
      "${var.join_command}",
    ]
  }

  depends_on = [
    module.worker
  ]
}
