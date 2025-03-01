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
