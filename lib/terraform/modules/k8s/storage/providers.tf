terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = local.kubeconfig_file
  }
}

provider "kubernetes" {
  config_path = local.kubeconfig_file
}
