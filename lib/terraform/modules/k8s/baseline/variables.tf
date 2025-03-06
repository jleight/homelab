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

    gateway = optional(object({
      version   = string
      namespace = optional(string, "gateway")
      install   = optional(string, "experimental")
      lb_pool   = optional(string, "10.245.0.0/24")
    }))
    cilium = optional(object({
      version       = string
      namespace     = optional(string, "kube-system")
      replace_proxy = optional(bool, true)
      bgp           = optional(bool, true)
    }))
    cert_manager = optional(object({
      version        = string
      namespace      = optional(string, "cert-manager")
      issuer         = optional(string, "selfsigned-test")
      test           = optional(bool, false)
      test_namespace = optional(string, "cert-manager-test")
    }))

    httpbin = optional(object({
      namespace = optional(string, "httpbin")
      count     = optional(number, 2)
    }))
  })
}
