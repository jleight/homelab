terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = local.kubeconfig_file
  }
}

provider "kubectl" {
  config_path = local.kubeconfig_file
}

provider "kubernetes" {
  config_path = local.kubeconfig_file
}
