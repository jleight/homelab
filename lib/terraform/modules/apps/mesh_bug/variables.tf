variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "vault" {
  description = "The name of the 1Password vault."
  type        = string
  default     = "Terraform"
}

variable "vernemq_host" {
  description = "In-cluster hostname of the CoreScope VerneMQ broker."
  type        = string
}

variable "vernemq_username" {
  description = "Username for the CoreScope VerneMQ broker."
  type        = string
}

variable "vernemq_password" {
  description = "Password for the CoreScope VerneMQ broker."
  type        = string
  sensitive   = true
}

variable "data_storage_class" {
  description = "StorageClass for the data volumes."
  type        = string
}

variable "gateway_namespace" {
  description = "Namespace for the gateway for public ingress."
  type        = string
}

variable "gateway_name" {
  description = "Name of the gateway for public ingress."
  type        = string
}

variable "gateway_section" {
  description = "Name of the gateway section for public ingress."
  type        = string
}

variable "gateway_domain" {
  description = "Domain for the gateway for public ingress."
  type        = string
}

variable "mesh_bug" {
  description = "MeshBug configuration."
  type = object({
    repository = string
    chart      = string
    version    = string

    subdomain = optional(string, "meshbug")
    path      = optional(string, "/")
  })
}
