terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
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

provider "kubectl" {
  config_path = local.kubeconfig_file
}

provider "kubernetes" {
  config_path = local.kubeconfig_file
}
