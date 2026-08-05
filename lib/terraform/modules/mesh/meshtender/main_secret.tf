# 32-byte AES master key, hex-encoded (64 chars), per MeshTender's expectations.
resource "random_id" "master_key" {
  count = local.enabled ? 1 : 0

  byte_length = 32
}

# Losing the master key means losing everything it wraps, and the only other copy
# lives in Terraform state, so mirror it into 1Password for the human to recover.
resource "onepassword_item" "master_key" {
  count = local.enabled ? 1 : 0

  title    = "MeshTender - Master Key"
  category = "password"
  vault    = local.vault_uuid

  password = local.master_key
  url      = "https://${var.meshtender.hosts.primary}"
}

resource "kubernetes_secret_v1" "app" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-secrets"

    labels = local.labels
  }

  data = {
    MESHTENDER_DATABASE_URL   = local.postgres_datasource
    MESHTENDER_MASTER_KEY     = local.master_key
    MESHTENDER_RESEND_API_KEY = local.resend_api_key
  }
}
