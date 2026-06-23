variable "env_directory" {
  description = "Path to the env directory."
  type        = string
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

variable "registry_host" {
  description = "Host of the OCI registry images are pulled from."
  type        = string
}

variable "registry_username" {
  description = "Username for pulling images from the registry."
  type        = string
}

variable "registry_password" {
  description = "Password for pulling images from the registry."
  type        = string
  sensitive   = true
}

variable "deployer_service_account_name" {
  description = "Name of the Woodpecker deployer ServiceAccount granted patch rights on the Deployment."
  type        = string
}

variable "deployer_service_account_namespace" {
  description = "Namespace of the Woodpecker deployer ServiceAccount."
  type        = string
}

variable "meshtender" {
  description = "MeshTender configuration."
  type = object({
    image  = string
    commit = string

    replicas = optional(number, 1)

    rp_name = optional(string, "MeshTender")

    hosts = object({
      root    = string
      www     = string
      auth    = string
      primary = string
    })
  })
}
