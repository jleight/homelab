data "kubernetes_secret_v1" "source" {
  count = local.enabled && !local.is_source ? 1 : 0

  metadata {
    namespace = var.source_namespace
    name      = local.secret_name
  }
}
