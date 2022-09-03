data "cloudinit_config" "user-data" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.yaml"
    content_type = "text/cloud-config"
    content      = file("${path.module}/templates/user-data.yaml")
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  dynamic "part" {
    for_each = var.user_data
    content {
      filename     = "init-${part.key}.yaml"
      content_type = "text/cloud-config"
      content      = part.value
      merge_type   = "list(append)+dict(recurse_array)+str()"
    }
  }
}

resource "hcloud_server" "node" {
  name               = var.name
  server_type        = var.server_type
  image              = "ubuntu-22.04"
  location           = "nbg1"
  ssh_keys           = var.authorized_keys
  user_data          = data.cloudinit_config.user-data.rendered
  placement_group_id = var.placement_group_id
  firewall_ids       = var.firewall_ids

  network {
    network_id = var.network_id
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
}
