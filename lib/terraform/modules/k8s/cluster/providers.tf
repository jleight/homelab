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
    talos = {
      source = "siderolabs/talos"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
