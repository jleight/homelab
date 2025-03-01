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
      disk              = string
      network_interface = string
      mac_address       = string
    }))
    kgateway = optional(object({
      crds  = string
      chart = string
    }))
    cilium = optional(object({
      chart         = string
      replace_proxy = optional(bool, true)
      gateway       = optional(bool, true)
    }))
  })
}
