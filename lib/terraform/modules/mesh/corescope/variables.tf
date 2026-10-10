variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for CoreScope. Provided by the namespace module."
  type        = string
}

variable "backup_storage_class" {
  description = "StorageClass for the Litestream backup PVC (SMB share on the NAS). The same path on this share is read by the restore initContainer and written by the Litestream sidecar — preserves DB across namespace moves."
  type        = string
}

variable "backup_storage_size" {
  description = "Size of the Litestream backup PVC on the NAS."
  type        = string
  default     = "100Gi"
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

variable "gateway_hostnames" {
  description = "Hostnames the HTTPRoute serves."
  type        = list(string)
  default     = []
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

    default_region = optional(string, null)
    regions        = optional(map(string), {})
    hash_regions   = optional(set(string), [])

    carto_key = optional(string, "cb1_2cqc_1_a1221d861884b76e40071515")

    map_defaults = optional(object({
      center = tuple([number, number])
      zoom   = optional(number, 9)
    }), null)

    channel_keys  = optional(map(string), {})
    hash_channels = optional(set(string), [])

    # The server holds packets in memory as well as SQLite; without a window
    # and cap it loads the whole history and grows until the node OOMs.
    # max_memory_mb also sets the server's Go soft limit (1.5x).
    packet_store = optional(object({
      retention_hours = optional(number, 168)
      max_memory_mb   = optional(number, 2048)
    }), {})

    # Transmissions older than this are deleted from SQLite by the ingestor.
    packet_days = optional(number, 30)

    # One-time full VACUUM to switch the DB to incremental auto-vacuum. The
    # app skips it once auto_vacuum=INCREMENTAL, which is stored in the DB
    # header and survives the Litestream restore, so it is safe to leave on.
    vacuum_on_startup = optional(bool, true)

    resources = optional(object({
      memory_request = optional(string, "3Gi")
      memory_limit   = optional(string, "4Gi")
    }), {})

    litestream = object({
      image   = string
      version = string
    })
  })
}
