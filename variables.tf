variable "hcloud_token" {
  sensitive = true
  type      = string
}
variable "cluster_api_token" {
  sensitive = true
  type      = string
}

variable "management_ssh_key_id" {
  type = string
}

variable "op_credentials" {
  sensitive = true
  type      = string
}
variable "op_token" {
  type      = string
  sensitive = true
}

variable "github_token" {
  sensitive = true
  type      = string
}
variable "gha_tf_api_token" {
  type      = string
  sensitive = true
}
