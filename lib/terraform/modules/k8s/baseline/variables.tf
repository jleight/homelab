variable "cluster_kubeconfig_file" {
  description = "Path to the cluster's kubeconfig file."
  type        = string
}

variable "kgateway_crds_version" {
  description = "The version of kgateway CRDs to install."
  type        = string
}

variable "kgateway_version" {
  description = "The version of kgateway to install."
  type        = string
}
