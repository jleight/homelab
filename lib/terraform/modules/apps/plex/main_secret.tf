resource "kubernetes_secret" "claim" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-claim"

    labels = local.labels
  }

  data = {
    claim = local.claim
  }
}
