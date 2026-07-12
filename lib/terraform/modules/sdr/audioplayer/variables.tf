variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "media_storage_class" {
  description = "StorageClass for the Media SMB share; recordings are read from its `radio` subfolder."
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

variable "audioplayer" {
  description = "audioplayer.php configuration."
  type = object({
    image   = string
    version = string

    timezone = optional(string, "UTC")

    subdomain = optional(string, "scanner")

    # Filesystem-activity logging to the container log: "quiet" (warnings only),
    # "info" (per-day summary builds), or "debug" (also every live scan/request).
    log_level = optional(string, "info")

    # Row cap for the initial "today" All-Calls load (bounds stat() work on the
    # live day). Past days are served in full from their summaries regardless.
    # 0 disables the cap.
    initial_limit = optional(number, 100)
  })

  validation {
    condition     = contains(["quiet", "info", "debug"], var.audioplayer.log_level)
    error_message = "audioplayer.log_level must be one of: quiet, info, debug."
  }
}

variable "systems" {
  description = "Trunk Recorder systems (short name, type, channel CSV) — used to locate recordings and build a labelled talkgroup file per system."
  type = list(object({
    short_name  = string
    type        = string
    channel_csv = string
  }))
}
