variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "openwebrx" {
  description = "Settings for OpenWebRX's Terraform-owned resources."
  type = object({
    data_storage_class = string

    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "owrx")
  })
}
