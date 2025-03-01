locals {
  cluster_kubeconfig_file = replace(var.cluster_kubeconfig_file, "////", "/")
}
