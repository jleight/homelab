terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
    radarr = {
      source = "devopsarr/radarr"
    }
  }
}

provider "kubernetes" {
  config_path = local.kubeconfig_file
}

provider "onepassword" {
  account = "my.1password.com"
}

provider "radarr" {
  url     = local.enabled ? "http://${data.kubernetes_service.radarr[0].spec[0].cluster_ip}" : ""
  api_key = var.radarr_api_key
}
