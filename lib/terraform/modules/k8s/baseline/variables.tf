variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "k8s_baseline" {
  description = "Settings for a baseline Kubernetes cluster."
  type = object({
    kubelet_cert_approver = object({
      repository = string
      version    = string
      url_format = string
    })

    gateway_crds = object({
      repository = string
      version    = string
      url_format = string
    })

    cilium = object({
      repository = string
      chart      = string
      version    = string
    })

    node_feature_discovery = object({
      repository = string
      chart      = string
      version    = string
    })

    amd_gpu = object({
      repository = string
      chart      = string
      version    = string
    })

    intel_gpu = object({
      repository = string
      chart      = string
      version    = string
    })
  })
}
