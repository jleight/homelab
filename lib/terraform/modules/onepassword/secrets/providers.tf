terraform {
  required_providers {
    onepassword = {
      source = "1Password/onepassword"
    }
  }
}

provider "onepassword" {
  account = "my.1password.com"
}
