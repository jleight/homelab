resource "random_password" "api_key" {
  count = local.enabled ? 1 : 0

  length  = 32
  special = false
}

# Full app config including MQTT credentials. Mounted at /app/data/config.json
# via subPath. Contains creds, so a Secret rather than a ConfigMap.
resource "kubernetes_secret_v1" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"

    labels = local.labels
  }

  data = {
    "config.json" = local.config_json
  }
}
