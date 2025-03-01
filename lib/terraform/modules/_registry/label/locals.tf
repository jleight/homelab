locals {
  input = {
    enabled       = var.enabled == null ? var.context.enabled : var.enabled
    repository    = var.repository == null ? var.context.repository : var.repository
    stack         = var.stack == null ? var.context.stack : var.stack
    component     = var.component == null ? var.context.component : var.component
    environment   = var.environment == null ? var.context.environment : var.environment
    subcomponents = compact(distinct(concat(coalesce(var.context.subcomponents, []), coalesce(var.subcomponents, []))))
  }
}
