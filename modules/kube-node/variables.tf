variable "kube_version" {
  type = string
}

variable "is_control_plane" {
  type = bool
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "node_address" {
  type = string
}
