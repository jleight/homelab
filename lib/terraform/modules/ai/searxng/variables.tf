variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
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
  description = "Domain for the gateway."
  type        = string
}

variable "searxng" {
  description = "SearXNG configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "search")
    path      = optional(string, "/")

    # Engine categories offered to callers. The upstream default mix is kept
    # (use_default_settings), so this only narrows what a query may reach.
    safe_search = optional(number, 0)
  })
}
