output "public_ipv4_address" {
  value = local.public_ipv4_address
}

output "private_ipv4_address" {
  value = local.private_ipv4_address
}

output "name" {
  value = local.name
}

output "kubeadm_join_command" {
  value = data.external.kubeadm_join.result.command
}
