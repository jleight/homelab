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

variable "failure_exclusions" {
  description = "Golang regular expressions matched against event messages that the failure alert should not report."
  type        = list(string)

  default = [
    "lookup [^ ]+ on [^ ]+:53: .*i/o timeout",
    "lookup [^ ]+ on [^ ]+:53: .*server misbehaving"
  ]
}

variable "image_event_sources" {
  description = "Kinds the info-severity Discord alert watches in the namespace."
  type        = set(string)
  default     = ["ImagePolicy"]
}
