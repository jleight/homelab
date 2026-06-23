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
  default     = ["core_scope", "mesh_bug"]
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
