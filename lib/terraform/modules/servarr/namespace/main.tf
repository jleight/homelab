resource "kubernetes_namespace" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = local.stack
  }
}
