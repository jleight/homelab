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
      schematic_id      = optional(string, "376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba")
      talos_version     = optional(string, "1.9.5")
      secure_boot       = optional(bool, false)
      install_disk      = string
      storage_disk      = string
      network_interface = string
      mac_address       = string
      ipv4_offset       = number
    }))
  })
}
