variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "readsb" {
  description = "readsb (1090 MHz ADS-B decoder) configuration."
  type = object({
    image   = string
    version = string

    replicas = optional(number, 1)

    latitude  = number
    longitude = number

    gain = optional(string, "autogain")

    device_resource = optional(string, "devices.k8s.leightha.us/sdr-adsb")
  })
}
