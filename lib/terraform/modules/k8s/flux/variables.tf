variable "k8s_flux" {
  description = "Settings for Flux and the operator that manages it."
  type = object({
    operator = object({
      repository = string
      chart      = string
      version    = string
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
  })
}
