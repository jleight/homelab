variable "namespace" {
  description = "The namespace the Provider and its Alerts are created in."
  type        = string
}

variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "failure_event_sources" {
  description = "Kinds the error-severity Discord alert watches in the namespace."
  type        = set(string)
  default = [
    "Kustomization",
    "GitRepository",
    "HelmRelease",
    "ImageRepository",
    "ImageUpdateAutomation"
  ]
}

variable "image_event_sources" {
  description = "Kinds the info-severity Discord alert watches in the namespace."
  type        = set(string)
  default     = ["ImagePolicy"]
}
