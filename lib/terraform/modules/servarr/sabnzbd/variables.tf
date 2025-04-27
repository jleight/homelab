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

variable "data_storage_class" {
  description = "StorageClass for the data volumes."
  type        = string
}

variable "media_storage_class" {
  description = "StorageClass for the media volume."
  type        = string
}

variable "gateway_namespace" {
  description = "Namespace for the gateway for private ingress."
  type        = string
}

variable "gateway_name" {
  description = "Name of the gateway for private ingress."
  type        = string
}

variable "gateway_domain" {
  description = "Domain for the gateway for private ingress."
  type        = string
}

variable "sabnzbd" {
  description = "SABnzbd configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "media")
    path      = optional(string, "/sabnzbd")

    servers = optional(map(object({
      secret_name = string
      port        = optional(number, 563)
      ssl         = optional(number, 1)
      ssl_verify  = optional(number, 3)
      priority    = number
      connections = number
      enabled     = optional(bool, true)
    })), {})
  })
}
