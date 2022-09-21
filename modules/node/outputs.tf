output "public_ipv4_address" {
  value = hcloud_server.node.ipv4_address
}

output "name" {
  value = hcloud_server.node.name
}

output "private_ipv4_address" {
  value = hcloud_server.node.network.*.ip[0]
}
