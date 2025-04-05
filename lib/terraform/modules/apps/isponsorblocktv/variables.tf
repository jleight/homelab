variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "isponsorblocktv" {
  description = "iSponsorBlockTV configuration."
  type = object({
    image   = string
    version = string

    api_key             = optional(string, "")
    skip_ads            = optional(bool, false)
    mute_ads            = optional(bool, false)
    skip_count_tracking = optional(bool, true)
    channel_whitelist   = optional(set(string), [])
    skip_categories     = optional(set(string), ["sponsor"])

    devices = optional(list(object({
      name      = string
      screen_id = string
    })), [])
  })
}
