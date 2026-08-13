terraform {
  required_providers {
    chaptarr = {
      source = "josh-archer/chaptarr"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
  }
}

provider "kubernetes" {
  config_path = local.kubeconfig_file
}

provider "onepassword" {
  account = "my.1password.com"
}

provider "chaptarr" {
  url     = local.enabled ? "http://${data.kubernetes_service_v1.chaptarr[0].spec[0].cluster_ip}${var.chaptarr_url_base}" : ""
  api_key = var.chaptarr_api_key
}
