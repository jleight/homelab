variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for the deployment."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the data volumes."
  type        = string
}

variable "media_storage_class" {
  description = "StorageClass for the media volume."
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

variable "db_host" {
  description = "Database host."
  type        = string
}

variable "db_port" {
  description = "Database port."
  type        = number
}

variable "db_username" {
  description = "Database username."
  type        = string
}

variable "db_password" {
  description = "Database password."
  type        = string
  sensitive   = true
}

variable "sonarr" {
  description = "Sonarr configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "media")
    path      = optional(string, "/sonarr")
    auth      = optional(string, "External")
  })
}
