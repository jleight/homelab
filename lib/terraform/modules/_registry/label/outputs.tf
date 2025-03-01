output "id" {
  description = "The generated ID string."
  value       = module.label.id
}

output "enabled" {
  description = "True of the module is enabled, false otherwise."
  value       = local.input.enabled
}

output "tags" {
  description = "The generated tags."
  value       = module.label.tags
}

output "context" {
  description = "Merged input to this module as a single object."
  value       = local.input

  precondition {
    condition     = local.input.repository != null
    error_message = "kt-label module requires `repository` or `context` to be defined."
  }
  precondition {
    condition     = local.input.stack != null
    error_message = "kt-label module requires `stack` or `context` to be defined."
  }
  precondition {
    condition     = local.input.component != null
    error_message = "kt-label module requires `component` or `context` to be defined."
  }
  precondition {
    condition     = local.input.environment != null
    error_message = "kt-label module requires `environment` or `context` to be defined."
  }
}

output "cloudposse_context" {
  description = "The context to pass into CloudPosse modules."
  value       = module.label.context
}
