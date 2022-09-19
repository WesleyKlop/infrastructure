terraform {
  required_version = ">= 1.2.0"

  cloud {
    organization = "w3ssl3y"

    workspaces {
      name = "cloudlab"
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.35.0"
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
