resource "kubernetes_service_account" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.name
  }
}

resource "kubernetes_service" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.name

    labels = local.labels
  }

  spec {
    port {
      name        = "http"
      port        = 80
      target_port = local.flood_port
    }

    selector = local.match_labels
  }
}
