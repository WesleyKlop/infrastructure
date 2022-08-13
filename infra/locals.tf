locals {
  ssh_key_id      = hcloud_ssh_key.tf-ssh-key.id
  ssh_key_private = tls_private_key.ssh-key.private_key_openssh
}
