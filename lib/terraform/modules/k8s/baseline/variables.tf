variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "network" {
  description = "Settings for the home network."
  type = object({
    interface    = string
    subnet       = string
    gateway_ipv4 = string
    gateway_ipv6 = string
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

    kubelet_cert_approver = optional(
      object({
        version = string
      }),
      { version = "v0.9.0" }
    )
    metrics_server = optional(
      object({
        version   = string
        namespace = optional(string, "kube-system")
      }),
      { version = "v3.12.2" }
    )

    gateway = optional(
      object({
        version   = string
        namespace = optional(string, "gateway")
        install   = optional(string, "experimental")
        lb_pool   = optional(string, "10.245.0.0/24")
      }),
      { version = "v1.2.1" }
    )
    cilium = optional(
      object({
        version       = string
        namespace     = optional(string, "kube-system")
        replace_proxy = optional(bool, true)
        bgp           = optional(bool, true)
      }),
      { version = "1.17.1" }
    )

    openebs = optional(object({
      version        = string
      namespace      = optional(string, "openebs")
      max_replicas   = optional(number, 3)
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
