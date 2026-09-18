variable "vault" {
  description = "The name of the vault."
  type        = string
  default     = "Terraform"
}

variable "prosody" {
  description = "Settings for the Prosody XMPP server's Terraform-owned resources."
  type = object({
    data_storage_class = string

    gateway_domain = string
    subdomain      = optional(string, "xmpp")

    admin_username = optional(string, "jleight")
    admin_item     = optional(string, "Prosody - Admin")
  })
}
