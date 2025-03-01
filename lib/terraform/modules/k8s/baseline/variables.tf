variable "cluster_kubeconfig_file" {
  description = "Path to the cluster's kubeconfig file."
  type        = string
}

variable "k8s_cluster" {
  description = "Settings for the Kubernetes cluster."
  type = object({
    domain    = string
    subdomain = string
    ip_offset = number
    nodes = map(object({
      mac_address = string
    }))
    kgateway = optional(object({
      crds  = string
      chart = string
    }))
  })
}
