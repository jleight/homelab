variable "cluster_kubeconfig_file" {
  description = "Path to the cluster's kubeconfig file."
  type        = string
}

variable "k8s_cluster_baseline" {
  description = "Settings for baselining the Kubernetes cluster."
  type = object({
    kgateway = optional(object({
      crds_version    = string
      service_version = string
    }))
  })
}
