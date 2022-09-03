terraform {
  required_version = ">= 1.2.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 4.30.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.0"
    }
  }
}
