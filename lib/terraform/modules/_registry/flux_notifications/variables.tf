variable "namespace" {
  description = "Namespace to create the Provider's secret in."
  type        = string
}

variable "vault" {
  description = "The name of the vault."
  type        = string
  default     = "Terraform"
}

variable "item" {
  description = "Title of the item holding the Discord webhook, split across its url and password fields."
  type        = string
  default     = "Discord - Flux Notifications"
}
