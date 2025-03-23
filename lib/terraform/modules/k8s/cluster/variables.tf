variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "network" {
  description = "Settings for the home network."
  type = object({
    interface    = string
    gateway_ipv4 = string
    gateway_ipv6 = string
    gateway_as   = number
    nameservers  = set(string)
  })
}

variable "k8s_cluster" {
  description = "Settings for the Kubernetes cluster."
  type = object({
    domain    = string
    subdomain = string

    nodes = map(object({
      enabled           = optional(bool, true)
      name              = string
      install_disk      = string
      storage_disk      = string
      network_interface = string
      mac_address       = string
      ipv4_offset       = number
    }))

    kubelet_cert_approver = object({
      version = string
    })

    metrics_server = object({
      version   = string
      namespace = optional(string, "kube-system")
    })

    prometheus = object({
      version   = string
      namespace = optional(string, "monitoring")
    })

    gateway = object({
      version   = string
      namespace = optional(string, "gateway")
      install   = optional(string, "experimental")
      lb_pool   = optional(string, "10.245.0.0/24")
    })

    cilium = object({
      version       = string
      namespace     = optional(string, "kube-system")
      replace_proxy = optional(bool, true)
      bgp_as        = optional(number)
    })

    openebs = optional(object({
      version        = string
      namespace      = optional(string, "openebs")
      test           = optional(bool, false)
      test_namespace = optional(string, "openebs-test")
    }))

    csi_smb = optional(object({
      version   = string
      namespace = optional(string, "kube-system")
    }))

    external_dns = optional(object({
      version   = string
      namespace = optional(string, "external-dns")
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
