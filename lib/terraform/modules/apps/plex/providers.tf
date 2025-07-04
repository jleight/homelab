terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = local.kubeconfig_file
  }
}

provider "kubernetes" {
  config_path = local.kubeconfig_file
}

provider "onepassword" {
  account = "my.1password.com"
}
