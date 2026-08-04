variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for Beacon. Provided by the namespace module."
  type        = string
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the frontend's HTTPRoute attaches to."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
  default = []
}

variable "gateway_domain" {
  description = "Load balancer domain the frontend is served under. The hostname is built as \"<subdomain>.<gateway_domain>\"."
  type        = string
}

variable "db_host" {
  description = "Database host."
  type        = string
}

variable "db_port" {
  description = "Database port."
  type        = number
}

variable "db_username" {
  description = "Database username."
  type        = string
}

variable "db_password" {
  description = "Database password."
  type        = string
  sensitive   = true
}

variable "vernemq_host" {
  description = "In-cluster hostname of the broker Beacon ingests from."
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

variable "beacon" {
  description = "Beacon configuration."
  type = object({
    beacon_server = object({
      image   = string
      version = string
    })

    beacon_web = object({
      image   = string
      version = string
    })

    subdomain = optional(string, "beacon")

    # Map view for the "All" tab. Null leaves the app on its world overview.
    map_center = optional(tuple([number, number]), null)
    map_zoom   = optional(number, null)

    # Wordmark in the top-left. Avoid "&" and "|" — the image's entrypoint
    # substitutes this value with sed and both are metacharacters there.
    app_name = optional(string, null)

    # Tabs to hide entirely. Options: Packets, Channels, Map, Nodes,
    # Observers, Routes, Traces, Analytics.
    disabled_tabs = optional(set(string), [])

    # Normally-hidden themes to reveal in the picker.
    enabled_themes = optional(set(string), [])

    # Skip the once-per-session load splash.
    skip_splash = optional(bool, null)

    # IATA overrides. Beacon only knows an observer's IATA from the MQTT topic;
    # display name and map coordinates come from here.
    iatas = optional(map(object({
      name = string
      lat  = number
      lng  = number
    })), {})

    # Region groupings surfaced by the API, each covering a set of IATAs.
    regions = optional(list(object({
      slug          = string
      name          = string
      display_order = optional(number)
      center_lat    = optional(number)
      center_lng    = optional(number)
      zoom_level    = optional(number)
      iatas         = list(string)
    })), [])

    # Hashtag channels — Beacon derives the PSK from the tag itself, so names
    # are given without the leading "#".
    hashtag_channels = optional(set(string), [])

    # Explicit channel keys, keyed by channel hash (first byte of SHA256 of the
    # key, hex). Beacon cannot derive these, hence the hash in the key position.
    channel_keys = optional(map(object({
      name = string
      key  = string
    })), {})

    # Regional transport scopes matched against TRANSPORT_FLOOD packets. Plain
    # names get "#" prepended by Beacon.
    scopes = optional(set(string), [])

    telemetry_retention  = optional(string, "672h")
    telemetry_resolution = optional(string, "1h")
    packet_retention     = optional(string, "720h")

    max_connections_per_ip = optional(number, 5)

    # Optional second ingest broker. Beacon has exactly two broker slots; slot 1
    # is always the in-cluster broker. Leaving this null means slot 2 stays
    # unconfigured and its worker never connects.
    second_broker = optional(object({
      url      = string
      username = optional(string, "")
      password = optional(string, "")
    }), null)
  })
}
