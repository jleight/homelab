variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "database_storage_class" {
  description = "StorageClass for the namespace-wide database cluster's volumes."
  type        = string
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
