module "notifications" {
  source  = "../../_registry/flux_notifications"
  context = local.context

  namespace = local.namespace
  vault     = var.vault

  depends_on = [kubectl_manifest.instance]
}
