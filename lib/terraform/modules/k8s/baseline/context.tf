variable "enabled" {
  description = "Set to false to prevent this module from creating any resources."
  type        = bool
  default     = null
}

variable "repository" {
  description = "The name of the repository."
  type        = string
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

variable "subcomponents" {
  description = "Additional values to add to the generated ID. New subcomponents are appended to the end of the list."
  type        = list(string)
  default     = []
}

variable "context" {
  description = "A single object for setting the entire context at once."

  type = object({
    enabled       = bool
    repository    = string
    stack         = string
    component     = string
    environment   = string
    subcomponents = list(string)
  })

  default = {
    enabled       = true
    repository    = null
    stack         = null
    environment   = null
    component     = null
    subcomponents = []
  }
}

module "this" {
  source = "../../_registry/label"

  enabled       = var.enabled
  repository    = var.repository
  stack         = var.stack
  component     = var.component
  environment   = var.environment
  subcomponents = var.subcomponents

  context = var.context
}

locals {
  enabled     = module.this.enabled
  repository  = module.this.context.repository
  stack       = module.this.context.stack
  component   = module.this.context.component
  environment = module.this.context.environment
}
