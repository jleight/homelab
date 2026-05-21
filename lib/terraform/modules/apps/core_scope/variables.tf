variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "vault" {
  description = "The name of the 1Password vault."
  type        = string
  default     = "Terraform"
}

variable "data_storage_class" {
  description = "StorageClass for the SQLite data PVC. Must be a local / single-replica class — distributed block storage corrupts SQLite."
  type        = string
}

variable "backup_storage_class" {
  description = "StorageClass for the Litestream backup PVC (SMB share on the NAS)."
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

variable "mqtt_gateway_listeners" {
  description = "Listener (section, hostname) pairs the VerneMQ WSS HTTPRoute attaches to."
  type = list(object({
    section  = string
    hostname = string
  }))
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

    # Channel name -> hex key for decrypting channel messages.
    channel_keys = optional(map(string), {})

    # Channel names (including the '#' prefix) whose keys are derived via
    # SHA256(name)[:16]. The ingestor auto-derives keys for these.
    hash_channels = optional(list(string), [])

    # IATA code used as the default in region filters.
    default_region = optional(string, null)

    # IATA code -> human-readable region name.
    regions = optional(map(string), {})

    # Default map center and zoom on the map page.
    map_defaults = optional(object({
      center = tuple([number, number])
      zoom   = optional(number, 9)
    }), null)

    litestream = object({
      image   = string
      version = string
    })

    vernemq = object({
      repository = string
      chart      = string
      version    = string

      # Tiny Python sidecar that VerneMQ calls during CONNECT/PUBLISH/SUBSCRIBE
      # to authorize external publishers. The code is mounted from a ConfigMap
      # into a stock python image — no custom image build.
      auth = object({
        image   = string
        version = string
      })
    })
  })
}
