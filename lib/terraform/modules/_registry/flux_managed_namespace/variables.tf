variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "pod_security_enforcement" {
  description = "The pod security enforcement level for the namespace."
  type        = string
  default     = "restricted"
}
