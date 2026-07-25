variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for pgtt. Provided by the namespace module."
  type        = string
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the public WSS HTTPRoute attaches to."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
  default = []
}

variable "gateway_domain" {
  description = "Load balancer domain the public WSS HTTPRoute is served under. The hostname is built as \"<subdomain>.<gateway_domain>\"."
  type        = string
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

variable "db_host" {
  description = "Database host."
  type        = string
}

variable "db_port" {
  description = "Database port."
  type        = number
}

variable "db_username" {
  description = "Database username."
  type        = string
}

variable "db_password" {
  description = "Database password."
  type        = string
  sensitive   = true
}

variable "expected_audiences" {
  description = "Additional accepted JWT audience values (e.g. the existing VerneMQ hostnames), so a device can reach pgtt whether its token targets the old host or pgtt's own hostname. pgtt's own hostname is always accepted."
  type        = list(string)
  default     = []
}

variable "internal_users" {
  description = "List of usernames that bypass the JWT path via username/password (in-cluster subscribers). One password is generated per name and surfaced via outputs."
  type        = list(string)
  default     = ["core_scope", "mesh_bug"]
}

variable "pgtt" {
  description = "pgtt configuration."
  type = object({
    image     = string
    commit    = string
    subdomain = optional(string, "pgtt")
    replicas  = optional(number, 2)
  })
}
