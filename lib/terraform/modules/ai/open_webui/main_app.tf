module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.open_webui.image
  image_version = var.open_webui.version

  # Startup migrations run in-process on every replica. This stays at 1 (see
  # the variable comment); pushing it higher needs ENABLE_DB_MIGRATIONS=false on
  # all but one designated pod, which a plain Deployment cannot express.
  replicas = var.open_webui.replicas

  port         = 8080
  service_port = 8080

  subdomain = var.open_webui.subdomain
  path      = var.open_webui.path

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

  env = {
    PORT     = "8080"
    DATA_DIR = "/app/backend/data"

    WEBUI_URL = "https://${local.hostname}"

    # Upstream defaults ENV to "dev" despite what the hardening page claims,
    # which serves the Swagger UI and the OpenAPI schema at /docs.
    ENV = "prod"

    # Signup is on by default and DEFAULT_USER_ROLE only gates what a new
    # account can do, not whether it can be created. The admin seeded in
    # main_password.tf turns it off in the database on first boot; this makes
    # sure nothing is open in the window before that happens.
    ENABLE_SIGNUP     = "false"
    DEFAULT_USER_ROLE = "pending"

    WEBUI_ADMIN_EMAIL = var.open_webui.admin_email
    WEBUI_ADMIN_NAME  = var.open_webui.admin_name

    # Served over HTTPS at the gateway, so the cookies can say so. Upstream
    # defaults to secure=false, samesite=lax.
    WEBUI_SESSION_COOKIE_SECURE    = "true"
    WEBUI_SESSION_COOKIE_SAME_SITE = "strict"

    # Defaults to "*".
    CORS_ALLOW_ORIGIN = "https://${local.hostname}"

    # Posting prompts and models to openwebui.com's community hub.
    ENABLE_COMMUNITY_SHARING = "false"

    # Installs pip packages named in the frontmatter of imported tools and
    # functions, at startup, from the public index.
    ENABLE_PIP_INSTALL_FRONTMATTER_REQUIREMENTS = "false"

    # Renovate owns the version; the app phoning home about it is noise.
    ENABLE_VERSION_UPDATE_CHECK = "false"

    ANONYMIZED_TELEMETRY = "false"
    SCARF_NO_ANALYTICS   = "true"
    DO_NOT_TRACK         = "true"

    DATABASE_POOL_SIZE         = tostring(var.open_webui.database_pool_size)
    DATABASE_POOL_MAX_OVERFLOW = tostring(var.open_webui.database_pool_max_overflow)

    VECTOR_DB                             = "pgvector"
    PGVECTOR_INITIALIZE_MAX_VECTOR_LENGTH = tostring(var.open_webui.pgvector_max_vector_length)

    # The db module's Database resource has the operator install pgvector as
    # superuser, so the app never needs to try; the owning role could not create
    # it anyway.
    PGVECTOR_CREATE_EXTENSION = "false"

    REDIS_URL                = local.redis_url
    WEBSOCKET_REDIS_URL      = local.redis_url
    WEBSOCKET_MANAGER        = "redis"
    ENABLE_WEBSOCKET_SUPPORT = "true"

    # Bifrost speaks OpenAI's wire format, so it is just a base URL swap. Ollama
    # is off: everything reaches models through the gateway.
    ENABLE_OPENAI_API   = "true"
    ENABLE_OLLAMA_API   = "false"
    OPENAI_API_BASE_URL = var.bifrost_base_url

    # Empty leaves the picker on whatever Bifrost lists rather than preselecting
    # one, which is the sane default for a chat UI fronting a gateway.
    DEFAULT_MODELS = var.open_webui.default_model

    # In MB and in files-per-request. Unset upstream, i.e. unlimited.
    RAG_FILE_MAX_SIZE  = tostring(var.open_webui.rag_file_max_size)
    RAG_FILE_MAX_COUNT = tostring(var.open_webui.rag_file_max_count)

    # SearXNG runs alongside in the ai namespace, ClusterIP-only. Open WebUI
    # calls it through its own aiohttp session rather than the web loader, so
    # ENABLE_LOCAL_WEB_FETCH stays false: the guard that keeps a model-chosen
    # URL from reaching the LAN does not stand between us and our own search
    # backend. The `<query>` placeholder the docs show is legacy -- v0.11.1
    # strips the query string off and builds the params itself -- so the bare
    # /search endpoint is what to hand it.
    ENABLE_WEB_SEARCH              = "true"
    WEB_SEARCH_ENGINE              = "searxng"
    SEARXNG_QUERY_URL              = var.searxng_query_url
    WEB_SEARCH_RESULT_COUNT        = tostring(var.open_webui.web_search_result_count)
    WEB_SEARCH_CONCURRENT_REQUESTS = tostring(var.open_webui.web_search_concurrent_requests)

    RAG_EMBEDDING_ENGINE    = var.open_webui.embedding_engine
    RAG_EMBEDDING_MODEL     = var.open_webui.embedding_model
    RAG_OPENAI_API_BASE_URL = var.bifrost_base_url
  }

  env_from_secrets = [local.secret_name]

  # envFrom does not roll the Deployment when the Secret changes, so a rotated
  # password or a re-minted Bifrost key would otherwise sit unused until the
  # next unrelated restart.
  pod_annotations = {
    "checksum/secret" = sha256(jsonencode(kubernetes_secret_v1.this[0].data))
  }

  # With Postgres and pgvector carrying the database and the vectors, this holds
  # uploaded files, the native embedding model's cache, and the RAG scratch
  # space. It stays ReadWriteMany (the module default) because Open WebUI
  # expects replicas to share it, and because a RollingUpdate would otherwise
  # deadlock surging a second pod against a ReadWriteOnce mount.
  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
      storage_size  = var.open_webui.storage_size
    }

    uploads = {
      storage_class = var.uploads_storage_class
      storage_size  = var.open_webui.uploads_storage_size
    }
  }

  # UPLOAD_DIR is hardcoded to DATA_DIR/uploads with no env override, so the SMB
  # share is nested inside the data volume rather than pointed at. The kubelet
  # sorts mounts by path depth, so the parent lands first. Splitting them this
  # way keeps the embedding model cache on cluster storage -- it is re-read on
  # every start -- while the user files, which are written once and served back
  # whole, live on the NAS.
  #
  # The local storage provider only ever does open()/read/os.remove on
  # UUID-named files: no locking, no rename, nothing SMB would mishandle. That
  # holds only because Postgres and pgvector carry the database and the vectors;
  # a SQLite webui.db or a Chroma directory here would be the network-storage
  # corruption the upstream docs warn about.
  volume_mounts = [
    {
      name       = "data"
      mount_path = "/app/backend/data"
    },
    {
      name       = "uploads"
      mount_path = "/app/backend/data/uploads"
    }
  ]
}
