variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "vault" {
  description = "The name of the vault."
  type        = string
  default     = "Terraform"
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

variable "gateway_section" {
  description = "Name of the gateway section for private ingress."
  type        = string
}

variable "plex" {
  description = "Plex configuration."
  type = object({
    image   = string
    version = string
  })
}
