terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
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

provider "kubectl" {
  config_path = local.kubeconfig_file
}

provider "kubernetes" {
  config_path = local.kubeconfig_file
}

provider "onepassword" {
  account = "my.1password.com"
}
