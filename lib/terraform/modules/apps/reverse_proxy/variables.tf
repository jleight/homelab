variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "public_https_refs" {
  description = "Gateway API parentRefs for public proxied routes."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
  default = []
}

variable "private_https_refs" {
  description = "Gateway API parentRefs for private (LAN-only) proxied routes."
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
