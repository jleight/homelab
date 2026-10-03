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
    extensions       = optional(set(string), [])

    # The databases this user owns. Defaults to a single database named after
    # the user; set it for apps that want several, like the *arrs' main and
    # log databases.
    databases = optional(set(string))
  }))
  default = {}

  validation {
    condition     = !contains(keys(var.managed_databases), "app")
    error_message = "\"app\" is a reserved database name."
  }

  # Two users owning the same database would fight over its Database CR.
  validation {
    condition = (
      length(flatten([for k, v in var.managed_databases : v.databases != null ? tolist(v.databases) : [k]])) ==
      length(toset(flatten([for k, v in var.managed_databases : v.databases != null ? tolist(v.databases) : [k]])))
    )
    error_message = "Each database can only be owned by one user."
  }
}
