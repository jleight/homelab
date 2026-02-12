terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 3.2.0"
    }
    sonarr = {
      source = "devopsarr/sonarr"
    }
  }
}

provider "kubernetes" {
  config_path = local.kubeconfig_file
}

provider "onepassword" {
  account = "my.1password.com"
}

provider "sonarr" {
  url     = local.enabled ? "http://${data.kubernetes_service.sonarr[0].spec[0].cluster_ip}" : ""
  api_key = var.sonarr_api_key
}
