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

variable "component" {
  description = "The name of the component."
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
    component   = string
    environment = string
  })

  default = {
    enabled     = true
    stack       = null
    component   = null
    environment = null
  }

  validation {
    condition     = coalesce(var.stack, var.context.stack) != null
    error_message = "Either stack or context.stack must be set."
  }

  validation {
    condition     = coalesce(var.component, var.context.component) != null
    error_message = "Either component or context.component must be set."
  }

  validation {
    condition     = coalesce(var.environment, var.context.environment) != null
    error_message = "Either environment or context.environment must be set."
  }
}

locals {
  enabled     = coalesce(var.enabled, var.context.enabled)
  stack       = coalesce(var.stack, var.context.stack)
  component   = coalesce(var.component, var.context.component)
  environment = coalesce(var.environment, var.context.environment)
}
