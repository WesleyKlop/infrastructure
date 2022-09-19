variable "repo_name" {
  type = string
}

variable "repo_description" {
  type = string
}

variable "argocd_url" {
  type = string
}

variable "control_plane_ip" {
  type = string
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "op_token" {
  type      = string
  sensitive = true
}
variable "op_credentials" {
  type      = string
  sensitive = true
}

variable "gha_tf_api_token" {
  type      = string
  sensitive = true
}
