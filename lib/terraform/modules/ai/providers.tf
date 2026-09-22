terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "onepassword" {
  account = "my.1password.com"
}
