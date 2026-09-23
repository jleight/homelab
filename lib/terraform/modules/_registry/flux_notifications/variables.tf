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
  description = "Kinds the error-severity Discord alert watches in the namespace. A kind in update_event_sources already reports its errors there, so it does not belong here too."
  type        = set(string)
  default = [
    "Kustomization",
    "GitRepository",
    "ImageRepository",
    "ImageUpdateAutomation"
  ]
}

variable "failure_exclusions" {
  description = "Golang regular expressions matched against event messages that neither alert should report."
  type        = list(string)

  default = [
    "lookup [^ ]+ on [^ ]+:53: .*i/o timeout",
    "lookup [^ ]+ on [^ ]+:53: .*server misbehaving"
  ]
}

variable "update_event_sources" {
  description = "Kinds the info-severity Discord alert watches in the namespace: a new image tag selected, or a chart installed or upgraded. Info severity forwards these kinds' errors as well."
  type        = set(string)
  default     = ["ImagePolicy", "HelmRelease"]
}
