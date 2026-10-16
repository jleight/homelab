module "notifications" {
  source  = "../../_registry/flux_notifications"
  context = local.context

  vault       = var.vault

  namespace   = local.namespace
  instance_id = one(kubectl_manifest.instance[*].id)
}
