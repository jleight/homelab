variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "vault" {
  description = "The name of the 1Password vault."
  type        = string
  default     = "Terraform"
}

variable "namespace" {
  description = "Namespace for MeshTender. Provided by the namespace module."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the Postgres data volumes."
  type        = string
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the HTTPRoute attaches to."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
  default = []
}

variable "ghcr_deploy_service_account_name" {
  description = "Name of the GHCR webhook ServiceAccount granted patch rights on the Deployment."
  type        = string
}

variable "ghcr_deploy_service_account_namespace" {
  description = "Namespace of the GHCR webhook ServiceAccount."
  type        = string
}

variable "meshtender" {
  description = "MeshTender configuration."
  type = object({
    image = string
    tag   = string

    replicas = optional(number, 1)

    rp_name = optional(string, "MeshTender")

    hosts = object({
      root    = string
      www     = string
      auth    = string
      primary = string
    })

    mail = object({
      from     = string
      reply_to = string
    })
  })
}
