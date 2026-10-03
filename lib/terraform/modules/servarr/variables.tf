variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "database_storage_class" {
  description = "StorageClass for the namespace-wide database cluster's volumes."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the apps' data volumes."
  type        = string
}

variable "media_storage_class" {
  description = "SMB-backed StorageClass for the shared Media share on nas02."
  type        = string
}

variable "incomplete_storage_class" {
  description = "StorageClass for SABnzbd's in-progress downloads."
  type        = string
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the apps' HTTPRoutes attach to."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
}

variable "gateway_domain" {
  description = "Domain for the gateway for private ingress."
  type        = string
}

variable "media_subdomain" {
  description = "Hostname the *arrs, SABnzbd and qBittorrent share, each under its own path."
  type        = string
  default     = "media"
}

variable "chaptarr" {
  description = "Settings for Chaptarr's Terraform-owned resources."
  type = object({
    path = optional(string, "/chaptarr")
    auth = optional(string, "External")
  })
  default = {}
}

variable "qbittorrent" {
  description = "Settings for qBittorrent's Terraform-owned resources."
  type = object({
    path = optional(string, "/qbittorrent")
  })
  default = {}
}

variable "radarr" {
  description = "Settings for Radarr's Terraform-owned resources."
  type = object({
    path = optional(string, "/radarr")
    auth = optional(string, "External")
  })
  default = {}
}

variable "romm" {
  description = "Settings for RomM's Terraform-owned resources."
  type = object({
    subdomain = optional(string, "roms")

    # The RetroArch bridge is served under this path on RomM's own hostname.
    # The gateway strips the prefix before forwarding, since the bridge routes
    # on root-relative paths.
    bridge_path = optional(string, "/_ra")
  })
  default = {}
}

variable "sabnzbd" {
  description = "Settings for SABnzbd's Terraform-owned resources."
  type = object({
    path = optional(string, "/sabnzbd")

    servers = optional(map(object({
      secret_name = string
      port        = optional(number, 563)
      ssl         = optional(number, 1)
      ssl_verify  = optional(number, 3)
      priority    = number
      connections = number
      enabled     = optional(bool, true)
    })), {})
  })
  default = {}
}

variable "sonarr" {
  description = "Settings for Sonarr's Terraform-owned resources."
  type = object({
    path = optional(string, "/sonarr")
    auth = optional(string, "External")
  })
  default = {}
}
