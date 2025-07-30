variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "cloudflare_api_token" {
  description = "API token for Cloudflare."
  type        = string
}

variable "network" {
  description = "Settings for the home network."
  type = object({
    interface   = string
    nameservers = set(string)
    gateway_as  = number
  })
}

variable "k8s_cluster" {
  description = "Settings for the Kubernetes cluster."
  type = object({
    domain    = string
    subdomain = string

    nodes = map(object({
      enabled           = optional(bool, true)
      name              = string
      schematic_id      = optional(string, "613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245")
      talos_version     = optional(string, "1.10.5")
      secure_boot       = optional(bool, false)
      install_disk      = string
      storage_disk      = optional(string, null)
      network_interface = string
      mac_address       = string
      vlan_id           = number
      ipv4_offset       = number
    }))
  })
}
