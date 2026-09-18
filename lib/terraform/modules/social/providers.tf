terraform {
  required_providers {
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
