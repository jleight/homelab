terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      # Pinned (against our usual unpinned convention): the helm library bundled
      # in newer provider releases fails to load the immich chart's
      # values.schema.json remote $ref ("invalid file url"). 3.1.1 bundles a helm
      # version that resolves it. Revisit once a later release fixes the regression.
      version = "3.2.0"
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
