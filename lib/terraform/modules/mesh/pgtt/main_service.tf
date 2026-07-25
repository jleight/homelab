resource "kubernetes_service_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.name

    labels = local.labels
  }

  spec {
    # ws: the public HTTPRoute backends here. mqtt: in-cluster subscribers
    # (CoreScope, MeshBug) at cutover.
    port {
      name        = "ws"
      port        = local.ws_port
      target_port = "ws"
    }

    port {
      name        = "mqtt"
      port        = local.tcp_port
      target_port = "mqtt"
    }

    selector = local.match_labels
  }
}
