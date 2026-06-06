# A Secret (not a ConfigMap) because the managed settings include the Z-Wave
# network security keys. The init container deep-merges this into the persisted
# settings.json.
resource "kubernetes_secret_v1" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"
  }

  data = {
    "settings.json" = local.config_json
  }
}
