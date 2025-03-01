terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    external = {
      source = "hashicorp/external"
    }
    local = {
      source = "hashicorp/local"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
    talos = {
      source = "siderolabs/talos"
    }
  }
}

provider "onepassword" {
  account = "my.1password.com"
}

provider "cloudflare" {
  api_token = local.cloudflare_api_token
}
