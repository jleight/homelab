variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "username" {
  description = "Current user's username."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into (shared with Forgejo)."
  type        = string
}

variable "postgres_database" {
  description = "Name of the Woodpecker database."
  type        = string
}

variable "postgres_host" {
  description = "Read/write service host of the Postgres cluster."
  type        = string
}

variable "postgres_username" {
  description = "Postgres role used to own and connect to the Woodpecker database."
  type        = string
}

variable "postgres_password" {
  description = "Password for the Postgres role."
  type        = string
  sensitive   = true
}

variable "workspace_storage_class" {
  description = "StorageClass for the throwaway per-pipeline workspace volumes (non-replicated/local)."
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

variable "forgejo_url" {
  description = "Base URL of the Forgejo instance used as the forge and OCI registry."
  type        = string
}

variable "forgejo_admin_username" {
  description = "Username of the Forgejo admin account used to provision the forge integration."
  type        = string
}

variable "forgejo_admin_password" {
  description = "Password of the Forgejo admin account used to provision the forge integration."
  type        = string
  sensitive   = true
}

variable "woodpecker_ci" {
  description = "Woodpecker CI configuration."
  type = object({
    repository = string
    chart      = string
    version    = string

    subdomain = optional(string, "ci")
  })
}
