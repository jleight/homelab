variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for CoreScope. Provided by the namespace module."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the SQLite data PVC. Must be a local / single-replica class — distributed block storage corrupts SQLite."
  type        = string
}

variable "backup_storage_class" {
  description = "StorageClass for the Litestream backup PVC (SMB share on the NAS). The same path on this share is read by the restore initContainer and written by the Litestream sidecar — preserves DB across namespace moves."
  type        = string
}

variable "data_storage_size" {
  description = "Size of the SQLite data PVC."
  type        = string
  default     = "5Gi"
}

variable "backup_storage_size" {
  description = "Size of the Litestream backup PVC on the NAS."
  type        = string
  default     = "100Gi"
}

variable "gateway_namespace" {
  description = "Namespace for the gateway for ingress."
  type        = string
}

variable "gateway_name" {
  description = "Name of the gateway for ingress."
  type        = string
}

variable "gateway_listeners" {
  description = "Listener (section, hostname) pairs the app HTTPRoute attaches to. The HTTPRoute serves every hostname listed."
  type = list(object({
    section  = string
    hostname = string
  }))
}

variable "vernemq_host" {
  description = "In-cluster hostname of the broker."
  type        = string
}

variable "vernemq_username" {
  description = "Username for the broker."
  type        = string
}

variable "vernemq_password" {
  description = "Password for the broker."
  type        = string
  sensitive   = true
}

variable "core_scope" {
  description = "CoreScope configuration."
  type = object({
    image   = string
    version = string

    path = optional(string, "/")

    # The app ships Caddy and Mosquitto in its container. In k8s we terminate
    # TLS at the gateway and use an external MQTT broker, so both are disabled.
    disable_caddy     = optional(bool, true)
    disable_mosquitto = optional(bool, true)

    channel_keys  = optional(map(string), {})
    hash_channels = optional(list(string), [])

    default_region = optional(string, null)
    regions        = optional(map(string), {})

    map_defaults = optional(object({
      center = tuple([number, number])
      zoom   = optional(number, 9)
    }), null)

    litestream = object({
      image   = string
      version = string
    })
  })
}
