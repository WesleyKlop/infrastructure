variable "hcloud_token" {
  sensitive = true
}

variable "cluster_api_token" {
  sensitive = true
}

variable "management_ssh_key_id" {
}

variable "argocd_ssh_key" {
  sensitive = true
}
