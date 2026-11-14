variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "database_storage_class" {
  description = "StorageClass for the namespace-wide database cluster's volumes."
  type        = string
}

variable "database_extensions" {
  description = "Extension images for the namespace-wide database cluster. The tags carry the Postgres major, so they move with the cluster's."
  type = object({
    vchord = object({
      image   = string
      version = string
    })
  })
}

variable "immich" {
  description = "Settings for Immich's Terraform-owned resources."
  type = object({
    media_storage_class = string

    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "photos")
  })
}

variable "isponsorblocktv" {
  description = "Settings for iSponsorBlockTV's Terraform-owned resources."
  type = object({
    device_name           = optional(string, "Apple TV 4K")
    device_screen_id_item = optional(string, "YouTube - Screen ID - Apple TV 4K")

    api_key             = optional(string, "")
    join_name           = optional(string, "iSponsorBlockTV")
    auto_play           = optional(bool, true)
    skip_ads            = optional(bool, true)
    mute_ads            = optional(bool, false)
    minimum_skip_length = optional(number, 0)
    skip_count_tracking = optional(bool, true)
    channel_whitelist   = optional(set(string), [])
    skip_categories     = optional(set(string), ["sponsor"])
  })
  default = {}
}

variable "mealie" {
  description = "Settings for Mealie's Terraform-owned resources."
  type = object({
    data_storage_class = string

    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "recipes")

    allow_signup = optional(bool, false)
  })
}

variable "orca_tasks" {
  description = "Settings for orca-tasks' Terraform-owned resources."
  type = object({
    attachments_storage_class = string

    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "tasks")
  })
}

variable "sure" {
  description = "Settings for Sure's Terraform-owned resources."
  type = object({
    data_storage_class = string

    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "finance")

    onboarding_state = optional(string, "open")

    # An OpenAI-compatible endpoint for the chat assistant and the background
    # categorization and merchant jobs. Null leaves AI off.
    ai = optional(object({
      base_url = string
      model    = string
      api_key  = optional(string, "lemonade")

      context_window      = optional(number, 32768)
      max_response_tokens = optional(number, 4096)
      request_timeout     = optional(number, 180)
      max_tool_calls      = optional(number, 2)
      response_timeout    = optional(number, 720)
      pdf_processing      = optional(bool, false)
    }))
  })
}
