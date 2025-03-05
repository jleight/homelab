variable "network" {
  description = "Settings for the home network."
  type = object({
    interface = string
    subnet    = string
    ip_offsets = object({
      gateway = number
    })
    nameservers = set(string)
  })
}

variable "cluster_kubeconfig_file" {
  description = "Path to the cluster's kubeconfig file."
  type        = string
}

variable "k8s_cluster" {
  description = "Settings for the Kubernetes cluster."
  type = object({
    domain    = string
    subdomain = string
    nodes = map(object({
      name              = string
      disk              = string
      network_interface = string
      mac_address       = string
      ip_offset         = number
    }))
    kgateway = optional(object({
      crds  = string
      chart = string
    }))
    cilium = optional(object({
      chart         = string
      replace_proxy = optional(bool, true)
      gateway       = optional(bool, true)
      bgp           = optional(bool, true)
    }))
    httpbin = optional(number, 0)
  })
}
