variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "username" {
  description = "Current user's username."
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

variable "immich" {
  description = "Immich configuration."
  type = object({
    repository = string
    chart      = string
    version    = string

    subdomain = optional(string, "photos")
    ingress   = optional(string, "public")

    immich_server = object({
      image   = string
      version = string
    })
  })
}
