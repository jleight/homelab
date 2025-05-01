variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "username" {
  description = "Current user's username."
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

variable "forgejo" {
  description = "Forgejo configuration."
  type = object({
    repository = string
    chart      = string
    version    = string

    subdomain = optional(string, "git")
  })
}
