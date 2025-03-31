variable "vault" {
  description = "The name of the vault."
  type        = string
  default     = "Terraform"
}

variable "cloudflare_api_token_item" {
  description = "The title of the item containing the Cloudflare API Token."
  type        = string
  default     = "Cloudflare - API Token"
}

variable "smb_nas02_item" {
  description = "The title of the item containing the SMB credentials for nas02."
  type        = string
  default     = "SMB - nas02"
}

variable "lets_encrypt_staging_item" {
  description = "The title of the item containing the Let's Encrypt staging configuration."
  type        = string
  default     = "Let's Encrypt - Staging"
}


variable "lets_encrypt_production_item" {
  description = "The title of the item containing the Let's Encrypt production configuration."
  type        = string
  default     = "Let's Encrypt - Production"
}
