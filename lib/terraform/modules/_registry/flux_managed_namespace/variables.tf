variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "name" {
  description = "The name of the namespace. Defaults to the name of the stack."
  type        = string
  default     = null
}

variable "instance" {
  description = "The value of the k8s app/instance label."
  type        = string
  default     = null
}

variable "part_of" {
  description = "The value of the k8s app/part-of label. Defaults to the name of the stack."
  type        = string
  default     = null
}

variable "pod_security_enforcement" {
  description = "The pod security enforcement level for the namespace."
  type        = string
  default     = "restricted"
}
