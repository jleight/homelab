resource "kubernetes_config_map_v1" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"
  }

  data = {
    "configuration.yaml" = local.config_yaml
  }
}
