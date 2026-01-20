terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.2.1"
    }
  }
}

provider "onepassword" {
  account = "my.1password.com"
}
