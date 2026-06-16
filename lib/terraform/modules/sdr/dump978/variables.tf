variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "dump978" {
  description = "dump978 (978 MHz UAT decoder) configuration."
  type = object({
    image   = string
    version = string

    device_resource = optional(string, "devices.k8s.leightha.us/sdr-uat")
  })
}
