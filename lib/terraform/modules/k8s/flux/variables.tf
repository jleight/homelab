variable "repository" {
  description = "Name of the GitHub repository, from the README front matter."
  type        = string
}

variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "backups_storage_class" {
  description = "SMB-backed StorageClass on nas02 for the image registry's volume, which keeps it off Longhorn and out of offsite backups."
  type        = string
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the image registry's HTTPRoute attaches to."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
}

variable "gateway_domain" {
  description = "Domain for the gateway for private ingress."
  type        = string
}

variable "k8s_flux" {
  description = "Settings for Flux and the operator that manages it."
  type = object({
    operator = object({
      repository = string
      chart      = string
      version    = string
    })

    image_build_controller = object({
      repository = string
      chart      = string
      version    = string
    })

    registry = object({
      image     = string
      version   = string
      size      = optional(string, "20Gi")
      subdomain = optional(string, "registry")
    })

    distribution = object({
      registry = optional(string, "ghcr.io/fluxcd")
      version  = optional(string, "2.x")
    })

    sync = object({
      url      = string
      ref      = optional(string, "refs/heads/main")
      path     = optional(string, "lib/flux/clusters/prod")
      interval = optional(string, "1m")
    })

    push = optional(object({
      url = string
    }))
  })
}
