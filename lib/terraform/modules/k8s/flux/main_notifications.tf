module "notifications" {
  source  = "../../_registry/flux_notifications"
  context = local.context

  enabled = local.enabled

  namespace = local.namespace
  vault     = var.vault
}
