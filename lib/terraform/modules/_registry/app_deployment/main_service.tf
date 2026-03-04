resource "kubernetes_service_account_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = local.name
  }
}

resource "kubernetes_service_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = local.name

    labels = local.labels
  }

  spec {
    port {
      name        = "http"
      port        = var.service_port
      target_port = var.port
    }

    dynamic "port" {
      for_each = var.extra_service_ports

      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
      }
    }

    selector = local.match_labels
  }
}
