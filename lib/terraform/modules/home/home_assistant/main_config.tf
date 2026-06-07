resource "kubernetes_config_map_v1" "config_overlay" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config-overlay"
  }

  data = {
    "overlay.yaml" = local.config_overlay
  }
}
