variable "env_directory" {
  description = "Path to the env directory."
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

    kubelet_cert_approver = optional(
      object({
        version = string
      }),
      { version = "v0.9.0" }
    )
    metrics_server = optional(
      object({
        version = string
      }),
      { version = "v0.7.2" }
    )
    openebs = optional(
      object({
        version   = string
        namespace = optional(string, "openebs")
      }),
      { version = "v4.2.0" }
    )

    csi_smb = optional(object({
      version   = string
      namespace = optional(string, "kube-system")
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
    external_dns = optional(object({
      version   = string
      namespace = optional(string, "external-dns")
    }))

    httpbin = optional(object({
      namespace = optional(string, "httpbin")
      count     = optional(number, 2)
    }))
  })
}
