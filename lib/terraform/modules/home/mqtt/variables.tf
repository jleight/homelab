variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for the broker. Provided by the namespace module."
  type        = string
}

variable "mqtt" {
  description = "VerneMQ broker configuration."
  type = object({
    repository = string
    chart      = string
    version    = string
  })
}
