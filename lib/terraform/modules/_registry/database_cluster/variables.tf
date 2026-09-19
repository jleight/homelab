variable "namespace" {
  description = "The name of the namespace for this database cluster."
  type        = string
}

variable "instances" {
  description = "The number of instances in the cluster."
  type        = number
  default     = 2
}

variable "data_storage_class" {
  description = "StorageClass for the data volume."
  type        = string
}

variable "storage" {
  description = "The amount of storage space for this cluster."
  type        = string
  default     = "10Gi"
}

variable "managed_databases" {
  description = "Configuration for each database in the cluster."
  type = map(object({
    password_length  = optional(number, 64)
    password_special = optional(bool, false)
  }))
  default = {}

  validation {
    condition     = !contains(keys(var.managed_databases), "app")
    error_message = "\"app\" is a reserved database name."
  }
}
