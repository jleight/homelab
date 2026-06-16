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

variable "gateway_namespace" {
  description = "Namespace for the gateway for private ingress."
  type        = string
}

variable "gateway_name" {
  description = "Name of the gateway for private ingress."
  type        = string
}

variable "gateway_section" {
  description = "Name of the gateway section for private ingress."
  type        = string
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

    script_url = optional(string, "https://raw.githubusercontent.com/TrunkRecorder/trunk-recorder/master/utils/audioplayer.php")

    timezone = optional(string, "UTC")

    subdomain = optional(string, "scanner")
  })
}

variable "systems" {
  description = "Trunk Recorder systems (short name, type, channel CSV) — used to locate recordings and build a labelled talkgroup file per system."
  type = list(object({
    short_name  = string
    type        = string
    channel_csv = string
  }))
}
