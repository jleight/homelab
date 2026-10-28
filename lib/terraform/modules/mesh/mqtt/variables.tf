variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for the broker. Provided by the namespace module."
  type        = string
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the public MQTT WSS HTTPRoute attaches to."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
  default = []
}

variable "gateway_hostnames" {
  description = "Hostnames the public MQTT WSS HTTPRoute serves."
  type        = list(string)
  default     = []
}

variable "internal_users" {
  description = "List of usernames that bypass the JWT path via username/password. One password is generated per name and surfaced via outputs."
  type        = list(string)
  default     = ["core_scope"]
}

variable "subscriber_users" {
  description = "List of usernames for read-only third-party subscribers. They authenticate with a generated password, may subscribe under meshcore/, and may never publish."
  type        = list(string)
  default     = ["meshtender", "neonx"]

  validation {
    condition     = length(setintersection(var.subscriber_users, var.internal_users)) == 0
    error_message = "A username cannot be both an internal user and a subscriber user."
  }
}

variable "mqtt" {
  description = "VerneMQ + auth webhook configuration."
  type = object({
    repository = string
    chart      = string
    version    = string

    auth = object({
      image   = string
      version = string
    })
  })
}
