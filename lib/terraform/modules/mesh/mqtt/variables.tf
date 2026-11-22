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

variable "external_users" {
  description = <<-EOT
    Third-party users, keyed by username. Each authenticates with a generated
    password. `read` allows subscribing under meshcore/. `write` lists MQTT topic
    filters (e.g. "meshtender/#") the user may publish to, and subscribe to.
    Everything else is denied.
  EOT

  type = map(object({
    read  = optional(bool, false)
    write = optional(list(string), [])
  }))

  default = {
    meshtender = {
      read  = true
      write = ["meshtender/#"]
    }
    neonx = {
      read = true
    }
  }

  validation {
    condition     = length(setintersection(keys(var.external_users), var.internal_users)) == 0
    error_message = "A username cannot be both an internal user and an external user."
  }

  # Keep write grants out of the mesh feed and system topics: the first level
  # must be a literal, and not meshcore or a $-topic.
  validation {
    condition = alltrue([
      for f in flatten([for c in values(var.external_users) : c.write]) :
      !contains(["meshcore", "+", "#", ""], split("/", f)[0]) && !startswith(f, "$")
    ])
    error_message = "Write filters must start with a literal topic level other than meshcore, and not a $-topic."
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
