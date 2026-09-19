variable "enabled" {
  description = "Whether or not any resources should be created."
  type        = bool
  default     = null
}

variable "stack" {
  description = "The name of the stack."
  type        = string
  default     = null
}

variable "environment" {
  description = "The name of the environment."
  type        = string
  default     = null
}

variable "context" {
  description = "A single object for setting the entire context at once."

  type = object({
    enabled     = bool
    stack       = string
    environment = string
  })

  default = {
    enabled     = true
    stack       = null
    environment = null
  }

  validation {
    condition     = coalesce(var.stack, var.context.stack) != null
    error_message = "Either stack or context.stack must be set."
  }

  validation {
    condition     = coalesce(var.environment, var.context.environment) != null
    error_message = "Either environment or context.environment must be set."
  }
}

locals {
  enabled     = coalesce(var.enabled, var.context.enabled)
  stack       = coalesce(var.stack, var.context.stack)
  environment = coalesce(var.environment, var.context.environment)

  context = {
    enabled     = local.enabled
    stack       = local.stack
    environment = local.environment
  }
}
