variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the flight-history PVC."
  type        = string
}

variable "readsb_host" {
  description = "In-cluster hostname of the readsb Beast server tar1090 ingests 1090 traffic from."
  type        = string
}

variable "readsb_port" {
  description = "Port of the readsb Beast server."
  type        = number
}

variable "dump978_host" {
  description = "In-cluster hostname of the dump978 server tar1090 ingests UAT traffic from."
  type        = string
}

variable "dump978_uat_port" {
  description = "Raw UAT (uat_in) port on the dump978 server."
  type        = number
}

variable "gateway_namespace" {
  description = "Namespace for the gateway for private ingress."
  type        = string
}

variable "gateway_name" {
  description = "Name of the gateway for private ingress."
  type        = string
}

variable "gateway_section" {
  description = "Name of the gateway section for private ingress."
  type        = string
}

variable "gateway_domain" {
  description = "Domain for the gateway for private ingress."
  type        = string
}

variable "tar1090" {
  description = "tar1090 (ADS-B/UAT map web UI) configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "adsb")
    path      = optional(string, "/")

    history_retention_days = optional(number, 365)
    storage_size           = optional(string, "5Gi")

    latitude  = number
    longitude = number
  })
}
