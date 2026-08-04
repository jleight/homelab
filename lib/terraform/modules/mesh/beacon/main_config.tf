resource "kubernetes_config_map_v1" "app" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"
  }

  data = {
    "config.yaml" = local.config_yaml
  }
}
