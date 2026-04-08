variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "gateway_namespace" {
  description = "Namespace for the gateway."
  type        = string
}

variable "private_gateway_name" {
  description = "Name of the private gateway."
  type        = string
}

variable "public_gateway_name" {
  description = "Name of the public gateway."
  type        = string
}

variable "gateway_section" {
  description = "Name of the gateway section."
  type        = string
}

variable "gateway_domain" {
  description = "Domain for the gateway."
  type        = string
}

variable "reverse_proxy" {
  description = "Reverse proxy configuration."
  type = object({
    image   = string
    version = string

    services = map(object({
      frontend_subdomain = string
      frontend_path      = optional(string, "/")
      backend_host       = string
      backend_port       = optional(number, 443)
      public             = optional(bool, false)
    }))
  })
}
