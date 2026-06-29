variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "rtl_tcp" {
  description = "rtl_tcp server configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "sdr")

    device_resource = optional(string, "devices.k8s.leightha.us/sdr-shortwave")
  })
}
