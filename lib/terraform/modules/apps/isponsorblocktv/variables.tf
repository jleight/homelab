variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "youtube_screen_id_apple_tv_4k" {
  description = "The title of the item containing the Screen ID for YouTube on the Apple TV 4K."
  type        = string
  sensitive   = true
}

variable "isponsorblocktv" {
  description = "iSponsorBlockTV configuration."
  type = object({
    image   = string
    version = string

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
}
