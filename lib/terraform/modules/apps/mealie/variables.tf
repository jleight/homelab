variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the data volumes."
  type        = string
}

variable "tunnel_kind" {
  description = "The kind of the tunnel for public ingress."
  type        = string
}

variable "tunnel_name" {
  description = "The name of the tunnel for public ingress."
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

variable "gateway_section" {
  description = "Name of the gateway section for private ingress."
  type        = string
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
    ingress   = optional(string, "public")

    allow_signup = optional(bool, false)
  })
}
