
data "cloudinit_config" "control-plane-config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.yaml"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init-control-plane.yaml", {
      api_token              = var.cluster_api_token
      network_id             = hcloud_network.kubernetes.id
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
  user_data = data.cloudinit_config.control-plane-config.rendered

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
    ]
  }
}