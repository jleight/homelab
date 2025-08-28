variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "dragonflydb" {
  description = "Dragonfly DB Operator configuration."
  type = object({
    repository = string
    version    = string
    url_format = string
  })
}
