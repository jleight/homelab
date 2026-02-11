terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubectl" {
  config_path = local.kubeconfig_file
}

provider "kubernetes" {
  config_path = local.kubeconfig_file
}
