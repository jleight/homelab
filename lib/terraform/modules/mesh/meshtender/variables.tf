variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for MeshTender. Provided by the namespace module."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the Postgres data volumes."
  type        = string
}

variable "gateway_namespace" {
  description = "Namespace for the gateway for ingress."
  type        = string
}

variable "gateway_name" {
  description = "Name of the gateway for ingress."
  type        = string
}

variable "gateway_listeners" {
  description = "Listener (section, hostname) pairs the app HTTPRoute attaches to. The first hostname is used as the WebAuthn relying-party ID/origin."
  type = list(object({
    section  = string
    hostname = string
  }))
}

variable "registry_host" {
  description = "Host of the OCI registry images are pulled from."
  type        = string
}

variable "registry_username" {
  description = "Username for pulling images from the registry."
  type        = string
}

variable "registry_password" {
  description = "Password for pulling images from the registry."
  type        = string
  sensitive   = true
}

variable "deployer_service_account_name" {
  description = "Name of the Woodpecker deployer ServiceAccount granted patch rights on the Deployment."
  type        = string
}

variable "deployer_service_account_namespace" {
  description = "Namespace of the Woodpecker deployer ServiceAccount."
  type        = string
}

variable "meshtender" {
  description = "MeshTender configuration."
  type = object({
    image  = string
    commit = string

    hosts = object({
      root    = string
      www     = string
      auth    = string
      primary = string
    })

    rp_name = optional(string, "MeshTender")

    radio = optional(object({
      freq_hz = optional(string, "910525000")
      bw_hz   = optional(string, "62500")
      sf      = optional(string, "7")
      cr      = optional(string, "5")
    }), {})
  })
}
