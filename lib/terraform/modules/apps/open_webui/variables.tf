variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the data volumes."
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
  description = "Domain for the gateway for private ingress."
  type        = string
}

variable "open_webui" {
  description = "Open WubUI configuration."
  type = object({
    repository = string
    chart      = string
    version    = string

    subdomain = optional(string, "llms")
    path      = optional(string, "/")
  })
}
