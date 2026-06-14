resource "kubernetes_config_map_v1" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.component}-config"
  }

  data = {
    "config.yml" = yamlencode({})
  }
}
