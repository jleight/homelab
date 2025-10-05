variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version."
  type        = string
}

variable "k8s_monitoring" {
  description = "Settings for monitoring a Kubernetes cluster."
  type = object({
    metrics_server = object({
      repository = string
      chart      = string
      version    = string
      enabled    = optional(bool, true)
    })

    prometheus = object({
      repository = string
      chart      = string
      version    = string
      enabled    = optional(bool, true)
    })
  })
}
