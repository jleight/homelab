variable "namespace" {
  description = "The namespace the registry Secret is created in."
  type        = string
}

variable "credentials" {
  description = "Registry credentials to write into the namespace. Set only in flux-system, where k8s/flux creates them; every other namespace leaves this null and copies flux-system's Secret instead."
  type = object({
    host     = string
    username = string
    password = string
  })
  default   = null
  sensitive = true
}

variable "source_namespace" {
  description = "The namespace the registry Secret is copied from when credentials is null."
  type        = string
  default     = "flux-system"
}
