variable "network_id" {
  type = string
}

variable "placement_group_id" {
  type = string
}

variable "name" {
  type = string
}

variable "server_type" {
  type = string
}

variable "firewall_ids" {
  type = list(string)
}

variable "authorized_keys" {
  type = list(string)
}

variable "ssh_private_key" {
  sensitive = true
  type      = string
}

variable "join_command" {
  sensitive = true
  type      = string
}
