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

variable "mealie" {
  description = "Mealie configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "recipes")
    path      = optional(string, "/")

    allow_signup = optional(bool, false)
  })
}
