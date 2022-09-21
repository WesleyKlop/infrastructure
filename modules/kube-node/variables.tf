variable "kube_version" {
  type = string
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "node_address" {
  type = string
}
