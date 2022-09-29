output "control-plane-ip" {
  value = module.control-plane.public_ipv4_address
}

output "public-key" {
  value = chomp(tls_private_key.ssh-key.public_key_openssh)
}
