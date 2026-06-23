variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for the deployment. Provided by the namespace module."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the /config volume and the Postgres recorder database."
  type        = string
}

variable "backups_storage_class" {
  description = "SMB-backed StorageClass for the /config/backups volume (HA's backup target on nas02)."
  type        = string
}

variable "mqtt_host" {
  description = "In-cluster hostname of the MQTT broker."
  type        = string
}

variable "mqtt_port" {
  description = "Plain MQTT TCP port of the broker."
  type        = number
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the HTTPRoute attaches to."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
  default = []
}

variable "gateway_domain" {
  description = "Domain for the gateway for private ingress."
  type        = string
}

variable "home_assistant" {
  description = "Home Assistant configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "home-internal")
    path      = optional(string, "/")

    # yq image for the config-overlay merge init container.
    yq = object({
      image   = string
      version = string
    })
  })
}
