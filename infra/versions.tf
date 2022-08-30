terraform {
  required_version = ">= 1.2.0"

  cloud {
    organization = "w3ssl3y"

    workspaces {
      name = "javelin"
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.35.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 4.30.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "github" {
  token = var.github_token
}
