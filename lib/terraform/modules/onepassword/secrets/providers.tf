terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 3.2.0"
    }
  }
}

provider "onepassword" {
  account = "my.1password.com"
}
