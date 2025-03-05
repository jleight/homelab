terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    http = {
      source = "hashicorp/http"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = local.cluster_kubeconfig_file
  }
}

provider "kubectl" {
  config_path = local.cluster_kubeconfig_file
}

provider "kubernetes" {
  config_path = local.cluster_kubeconfig_file
}
