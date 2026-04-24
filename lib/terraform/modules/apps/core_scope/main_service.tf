resource "kubernetes_service_v1" "this" {
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
      target_port = local.port
    }

    selector = local.match_labels
  }
}
