variable "sudo_password" {
  description = "The sudo password for this machine."
  type        = string
  sensitive   = true
}

variable "dot_kube_directory" {
  description = "Path to your .kube directory."
  type        = string
}

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
