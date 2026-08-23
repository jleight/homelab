variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
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

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "bifrost"
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

variable "vault" {
  description = "The name of the vault."
  type        = string
  default     = "Terraform"
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
  description = "Domain for the gateway."
  type        = string
}

variable "bifrost" {
  description = "Bifrost configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "ai")
    path      = optional(string, "/")

    extra_allowed_origins = optional(list(string), [])

    request_timeout_seconds     = optional(number, 3600)
    stream_idle_timeout_seconds = optional(number, 3600)

    lemonade = object({
      url     = string
      api_key = optional(string, "lemonade")
    })
  })
}
