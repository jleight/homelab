variable "enabled" {
  description = "Whether or not this module should create any resources."
  type        = bool
  default     = true
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
    component     = null
    environment   = null
    subcomponents = []
  }
}
