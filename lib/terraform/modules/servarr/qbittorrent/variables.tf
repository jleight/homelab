variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for the deployment."
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

variable "flood" {
  description = "Flood configuration."
  type = object({
    image   = string
    version = string

    subdomain = string
    port      = optional(number, 3000)
    path      = string
  })
}

variable "qbittorrent" {
  description = "qBittorrent configuration."
  type = object({
    image   = string
    version = string
  })
}
