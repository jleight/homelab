resource "kubernetes_config_map_v1" "litestream" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-litestream"

    labels = local.labels
  }

  data = {
    "litestream.yml" = local.litestream_config
  }
}
