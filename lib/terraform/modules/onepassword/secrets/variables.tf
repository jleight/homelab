variable "vault" {
  description = "The name of the vault."
  type        = string
  default     = "Terraform"
}

variable "tailscale_k8s_operator_item" {
  description = "The title of the item containing the OAuth client details for the Tailscale Operator."
  type        = string
}

variable "cloudflare_api_token_item" {
  description = "The title of the item containing the Cloudflare API Token."
  type        = string
}

variable "lets_encrypt_item" {
  description = "The title of the item containing the Let's Encrypt staging configuration."
  type        = string
}

variable "smb_nas02_item" {
  description = "The title of the item containing the SMB credentials for nas02."
  type        = string
}
