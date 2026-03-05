resource "kubernetes_secret_v1" "claim" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-claim"
  }

  data = {
    claim = local.claim
  }
}
