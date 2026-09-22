variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "database_storage_class" {
  description = "StorageClass for the Postgres cluster's data volume."
  type        = string
}

variable "lemonade" {
  description = "The OpenAI-compatible model server on the LAN that Open WebUI talks to."

  type = object({
    url     = string
    api_key = optional(string, "lemonade")
  })
}

variable "searxng" {
  description = "SearXNG configuration."

  type = object({
    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "search")
  })
}

variable "open_webui" {
  description = "Open WebUI configuration."

  type = object({
    data_storage_class    = string
    uploads_storage_class = string

    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "llms")

    admin_email = optional(string, "open-webui@jleight.com")
    admin_name  = optional(string, "Jonathon Leight")
  })
}

variable "turnstone" {
  description = "Turnstone configuration."

  type = object({
    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "turnstone")
  })
}
