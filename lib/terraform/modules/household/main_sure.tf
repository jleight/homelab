locals {
  sure_domain    = "${var.sure.subdomain}.${var.sure.gateway_domain}"
  sure_db        = module.database_cluster.databases["sure"]
  sure_redis_url = "redis://sure-cache.${module.namespace.name}.svc.cluster.local:6379/0"

  sure_ai = var.sure.ai == null ? {} : {
    OPENAI_URI_BASE = var.sure.ai.base_url
    OPENAI_MODEL    = var.sure.ai.model

    # Sure's defaults (2048 and 512) are sized for tiny local models and leave
    # no room for the category list in the categorization prompt.
    LLM_CONTEXT_WINDOW      = tostring(var.sure.ai.context_window)
    LLM_MAX_RESPONSE_TOKENS = tostring(var.sure.ai.max_response_tokens)

    # Custom endpoints are not streamed and a chat turn can chain tool calls,
    # so the whole-turn budget has to cover every call:
    # (1 + max tool calls) * request timeout, plus headroom.
    OPENAI_REQUEST_TIMEOUT             = tostring(var.sure.ai.request_timeout)
    ASSISTANT_MAX_TOOL_CALL_ITERATIONS = tostring(var.sure.ai.max_tool_calls)
    AI_RESPONSE_TIMEOUT                = tostring(var.sure.ai.response_timeout)

    # System health's live probes. The 5s default cuts off the PDF vision
    # probe mid-reply even though the model answers it fine.
    AI_HEALTH_PROBE_TIMEOUT = tostring(var.sure.ai.probe_timeout)

    # PDF import sends page images, so it needs a vision-capable model.
    OPENAI_SUPPORTS_PDF_PROCESSING = tostring(var.sure.ai.pdf_processing)

    # Without this Sure uses OpenAI's hosted vector-store API, which no local
    # endpoint implements. The embeddings come from OPENAI_URI_BASE too.
    VECTOR_STORE_PROVIDER = "pgvector"
    EMBEDDING_MODEL       = var.sure.ai.embedding_model
    EMBEDDING_DIMENSIONS  = tostring(var.sure.ai.embedding_dimensions)
  }
}

# Signs sessions and cookies. Regenerating it only logs everyone out.
resource "random_bytes" "sure_secret_key_base" {
  length = 64
}

# Active Record encryption keys. These protect encrypted columns, such as
# linked-account credentials, so regenerating them makes that data
# unreadable.
resource "random_password" "sure_encryption_primary_key" {
  length  = 32
  special = false
}

resource "random_password" "sure_encryption_deterministic_key" {
  length  = 32
  special = false
}

resource "random_password" "sure_encryption_key_derivation_salt" {
  length  = 32
  special = false
}

resource "kubernetes_secret_v1" "sure" {
  metadata {
    namespace = module.namespace.name
    name      = "sure"
  }

  data = merge(var.sure.ai == null ? {} : { OPENAI_ACCESS_TOKEN = var.sure.ai.api_key }, {
    SECRET_KEY_BASE   = random_bytes.sure_secret_key_base.hex
    POSTGRES_PASSWORD = module.database_cluster.passwords["sure"]

    ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY         = random_password.sure_encryption_primary_key.result
    ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY   = random_password.sure_encryption_deterministic_key.result
    ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT = random_password.sure_encryption_key_derivation_salt.result
  })
}


# Values the containers read with envFrom.
resource "kubernetes_config_map_v1" "sure_env" {
  metadata {
    namespace = module.namespace.name
    name      = "sure-env"
  }

  data = merge(local.sure_ai, {
    SELF_HOSTED = "true"
    APP_DOMAIN  = local.sure_domain

    # The gateway terminates TLS, so the pod speaks plain HTTP but every
    # client connection is HTTPS. Forcing SSL would redirect the probes.
    RAILS_FORCE_SSL  = "false"
    RAILS_ASSUME_SSL = "true"

    # Only the default for a fresh install; the admin settings own it after.
    ONBOARDING_STATE = var.sure.onboarding_state

    # There is no SMTP, so a confirmation email could never arrive.
    REQUIRE_EMAIL_CONFIRMATION = "false"

    DB_HOST       = module.database_cluster.host
    DB_PORT       = tostring(module.database_cluster.port)
    POSTGRES_DB   = local.sure_db.database
    POSTGRES_USER = local.sure_db.username
    # libpq reads this, since database.yml has no sslmode of its own.
    PGSSLMODE = "require"

    REDIS_URL = local.sure_redis_url
  })
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "sure_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "sure-subst"
  }

  data = {
    data_storage_class  = var.sure.data_storage_class
    gateway_parent_refs = jsonencode(var.sure.gateway_refs)
    domain              = local.sure_domain
    secret_name         = kubernetes_secret_v1.sure.metadata[0].name
    secret_checksum     = "sha256:${sha256(jsonencode(kubernetes_secret_v1.sure.data))}"
    env_checksum        = "sha256:${sha256(jsonencode(kubernetes_config_map_v1.sure_env.data))}"
  }
}
