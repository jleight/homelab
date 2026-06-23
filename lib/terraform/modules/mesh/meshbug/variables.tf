variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for MeshBug. Provided by the namespace module."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the postgres data volumes."
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

variable "gateway_domain" {
  description = "Domain for the gateway for public ingress."
  type        = string
}

variable "vernemq_host" {
  description = "In-cluster hostname of the broker."
  type        = string
}

variable "vernemq_username" {
  description = "Username for the broker."
  type        = string
}

variable "vernemq_password" {
  description = "Password for the broker."
  type        = string
  sensitive   = true
}

variable "mesh_bug" {
  description = "MeshBug configuration."
  type = object({
    repository = string
    chart      = string
    version    = string

    subdomain = optional(string, "meshbug")
    path      = optional(string, "/")
  })
}
