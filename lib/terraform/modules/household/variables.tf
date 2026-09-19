variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "database_storage_class" {
  description = "StorageClass for the namespace-wide database cluster's volumes."
  type        = string
}

variable "mealie" {
  description = "Settings for Mealie's Terraform-owned resources."
  type = object({
    data_storage_class = string

    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "recipes")

    allow_signup = optional(bool, false)
  })
}
