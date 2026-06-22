# 32-byte AES master key, hex-encoded (64 chars), per MeshTender's expectations.
resource "random_id" "master_key" {
  count = local.enabled ? 1 : 0

  byte_length = 32
}

resource "kubernetes_secret_v1" "app" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-secrets"

    labels = local.labels
  }

  data = {
    MESHTENDER_DATABASE_URL = local.postgres_datasource
    MESHTENDER_MASTER_KEY   = local.master_key
  }
}
