terraform {
  cloud {
    organization = "w3ssl3y"

    workspaces {
      name = "javelin"
    }
  }
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 1.0"
}