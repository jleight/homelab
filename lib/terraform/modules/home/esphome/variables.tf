variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for the deployment. Provided by the namespace module."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the /config volume."
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

variable "esphome" {
  description = "ESPHome dashboard configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "esphome")
    path      = optional(string, "/")
  })
}
