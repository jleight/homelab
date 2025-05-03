variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "postgres" {
  description = "Postgres configuration."
  type = object({
    repository = string
    chart      = string
    version    = string
  })
}
