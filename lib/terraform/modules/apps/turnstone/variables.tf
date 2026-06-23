variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the data + Postgres volumes."
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
  description = "Domain for the gateway for private ingress."
  type        = string
}

variable "turnstone" {
  description = "Turnstone configuration."
  type = object({
    image   = string
    version = string

    # Front-door subdomain for the console (server nodes aren't exposed).
    subdomain = optional(string, "turnstone")

    # Number of server (worker) nodes to spin up. Each is a separate, distinctly
    # addressable instance the console discovers and proxies into.
    server_count = optional(number, 1)

    # Per-pod cap on each server's ephemeral /data + /workspace (emptyDir) scratch.
    scratch_size_limit = optional(string, "5Gi")

    # OpenAI-compatible LLM endpoint passed to server nodes as a boot-time
    # default (also configurable later in the console Models tab).
    llm_base_url = string

    # SearxNG metasearch image backing the server nodes' web_search tool.
    searxng = object({
      image   = string
      version = string
    })
  })
}
