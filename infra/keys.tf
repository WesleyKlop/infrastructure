resource "tls_private_key" "ssh-key" {
  algorithm = "ED25519"
}

resource "tls_private_key" "deploy-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "tf-ssh-key" {
  name       = "tf-ssh-key"
  public_key = tls_private_key.ssh-key.public_key_openssh
}
