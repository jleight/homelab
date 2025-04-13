variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the data volumes."
  type        = string
}

variable "gateway_namespace" {
  description = "Namespace for the gateway."
  type        = string
}

variable "gateway_name" {
  description = "Name of the gateway."
  type        = string
}

variable "gateway_domain" {
  description = "Domain for the gateway."
  type        = string
}

variable "smokeping" {
  description = "SmokePing configuration."
  type = object({
    image   = string
    version = string

    storage_size = optional(string, "100Mi")

    owner         = string
    contact_email = string
    time_zone     = optional(string, "Etc/UTC")
    subdomain     = string

    site_title  = optional(string, "Network Latency Grapher")
    site_remark = optional(string, "My homelab's network latency.")

    smtp_server      = optional(string, "smtp.example.com")
    smtp_port        = optional(number, 587)
    alert_to_email   = optional(string, "example@example.com")
    alert_from_email = optional(string, "example@example.com")

    targets_dns = map(object({
      name  = string
      hosts = list(string)
    }))

    targets_external = map(object({
      name = string
      host = string
    }))

    targets_internal = map(object({
      name = string
      host = string
    }))
  })
}
