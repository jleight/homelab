# Signs session cookies and JWTs. Open WebUI has no fallback for this -- it
# refuses to start unset -- and rotating it logs everyone out, so it lives here
# rather than being left to the image's self-generated file on the data volume,
# which would not survive the volume being recreated.
resource "random_password" "webui_secret_key" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = local.name
  }

  data = {
    DATABASE_URL    = local.database_url
    PGVECTOR_DB_URL = local.database_url

    # Both the chat models and, when embedding_engine is "openai", the
    # embeddings authenticate to Bifrost with the same virtual key.
    OPENAI_API_KEY     = local.bifrost_api_key
    RAG_OPENAI_API_KEY = local.bifrost_api_key

    WEBUI_SECRET_KEY = random_password.webui_secret_key[0].result

    WEBUI_ADMIN_PASSWORD = local.admin_password
  }
}
