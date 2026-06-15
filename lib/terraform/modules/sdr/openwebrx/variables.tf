variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the data volumes."
  type        = string
}

variable "rtl_tcp_host" {
  description = "In-cluster hostname of the rtl_tcp server OpenWebRX connects to."
  type        = string
}

variable "rtl_tcp_port" {
  description = "Port of the rtl_tcp server OpenWebRX connects to."
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

variable "vault" {
  description = "The name of the vault."
  type        = string
  default     = "Terraform"
}

variable "openwebrx" {
  description = "OpenWebRX configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "owrx")
    path      = optional(string, "/")

    timezone = optional(string, "America/New_York")

    # Receiver identity, seeded into settings.json by the init container.
    receiver = object({
      name            = string
      location        = string
      asl             = number
      admin           = string
      country         = string
      bandplan_region = number
      gps = object({
        lat = number
        lon = number
      })
    })

    # SDR device + band profiles, passed through verbatim into settings.json's
    # `sdrs` key. Free-form (OpenWebRX's own schema), so typed as `any`. Omit
    # rf_gain here to keep it tunable in the web UI.
    sdrs = any
  })
}
