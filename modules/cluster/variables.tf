variable "kube_version" {
  type = string
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "control_plane" {
  type = string
}
variable "workers" {
  type = map(string)
}
