module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.anything_llm.image
  image_version = var.anything_llm.version

  port         = 3001
  service_port = 3001

  ingress_enabled = var.anything_llm.public

  subdomain = var.anything_llm.subdomain
  path      = var.anything_llm.path

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

  # The image runs as uid/gid 1000 and writes to the storage volume, so the
  # kubelet has to hand the mount over to that group.
  fs_group = 1000

  env = {
    STORAGE_DIR = "/app/server/storage"
    SERVER_PORT = "3001"

    DISABLE_TELEMETRY = "true"

    # The `pg` image defaults to pgvector already; naming it keeps the wiring
    # visible next to the connection string that feeds it.
    VECTOR_DB = "pgvector"

    # Bifrost speaks OpenAI's wire format, so it is just a base path swap.
    LLM_PROVIDER                      = "generic-openai"
    GENERIC_OPEN_AI_BASE_PATH         = var.bifrost_base_url
    GENERIC_OPEN_AI_MODEL_PREF        = var.anything_llm.model
    GENERIC_OPEN_AI_MODEL_TOKEN_LIMIT = tostring(var.anything_llm.model_token_limit)

    EMBEDDING_ENGINE     = var.anything_llm.embedding_engine
    EMBEDDING_MODEL_PREF = var.anything_llm.embedding_model
  }

  env_from_secrets = [local.secret_name]

  # envFrom does not roll the Deployment when the Secret changes, so a rotated
  # password or a re-minted Bifrost key would otherwise sit unused until the
  # next unrelated restart.
  pod_annotations = {
    "checksum/secret" = sha256(jsonencode(kubernetes_secret_v1.this[0].data))
  }

  # With the `pg` image both the database and the vectors live in Postgres, so
  # this volume only holds the cached native embedding model and the collector's
  # scratch space for documents being parsed. Losing it costs a re-download.
  persistent_volume_claims = {
    storage = {
      storage_class = var.data_storage_class
      storage_size  = var.anything_llm.storage_size
    }
  }

  volume_mounts = [
    {
      name       = "storage"
      mount_path = "/app/server/storage"
    }
  ]
}
