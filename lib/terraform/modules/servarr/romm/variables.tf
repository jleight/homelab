variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "vault" {
  description = "The name of the vault."
  type        = string
  default     = "Terraform"
}

variable "namespace" {
  description = "Namespace for the deployment."
  type        = string
}

variable "media_storage_class" {
  description = "StorageClass for the media volume."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the bridge pairings data volume."
  type        = string
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the HTTPRoutes attach to (HTTPS section). The HTTP bridge route reuses the same gateways' http section."
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

variable "romm" {
  description = "RomM configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "roms")
    path      = optional(string, "/")

    bridge = object({
      image   = string
      version = string
      digest  = string

      # Served under this path on RomM's own hostname (not a separate
      # subdomain). The gateway strips the prefix before forwarding, since the
      # bridge routes on root-relative paths.
      path = optional(string, "/_ra")

      index_refresh_interval = optional(string, "1h")
      platform_map           = optional(string)
      log_level              = optional(string, "info")
    })
  })
}
