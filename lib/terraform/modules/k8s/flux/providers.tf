terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
    helm = {
      source = "hashicorp/helm"
    }
    http = {
      source = "hashicorp/http"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

provider "onepassword" {
  account = "my.1password.com"
}
