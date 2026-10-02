variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "database_storage_class" {
  description = "StorageClass for the namespace-wide database cluster's volumes."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the apps' data volumes."
  type        = string
}
