variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the app data volume."
  type        = string
}

variable "uploads_storage_class" {
  description = "StorageClass for the uploaded-files volume."
  type        = string
}

variable "db_host" {
  description = "Database host."
  type        = string
}

variable "db_port" {
  description = "Database port."
  type        = number
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "openwebui"
}

variable "db_username" {
  description = "Database username."
  type        = string
}

variable "db_password" {
  description = "Database password."
  type        = string
  sensitive   = true
}

variable "bifrost_base_url" {
  description = "OpenAI-compatible base URL for the Bifrost gateway (including /v1)."
  type        = string
}

variable "searxng_query_url" {
  description = "Cluster-internal SearXNG search endpoint."
  type        = string
}

variable "vault" {
  description = "The name of the vault."
  type        = string
  default     = "Terraform"
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the HTTPRoute attaches to."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
  default = []
}

variable "gateway_domain" {
  description = "Domain for the gateway."
  type        = string
}

variable "open_webui" {
  description = "Open WebUI configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "llms")
    path      = optional(string, "/")

    # Seeds the first admin account, after which signup turns itself off. The
    # password is generated and lands in 1Password under "Open WebUI".
    admin_email = optional(string, "open-webui@jleight.com")
    admin_name  = optional(string, "Jonathon Leight")

    # Pages fetched per search, then embedded and retrieved against. Upstream
    # defaults to 3. Each one is a page fetch plus a CPU embedding pass, so this
    # is the knob that decides how long a searched answer takes to start.
    web_search_result_count = optional(number, 5)

    # 0 means unbounded. Bounded so a single search cannot open a fetch per
    # result at once against whatever the crawler finds.
    web_search_concurrent_requests = optional(number, 4)

    # Uploads land on the SMB share, which is also where litestream and the
    # Home Assistant backups live, so an unbounded upload is somebody else's
    # outage. Upstream leaves both of these unset, meaning unlimited.
    rag_file_max_size  = optional(number, 100)
    rag_file_max_count = optional(number, 10)

    # Startup runs Alembic migrations in-process, and every replica of a plain
    # Deployment would run them at once. Going above 1 means designating a
    # migrating replica and setting ENABLE_DB_MIGRATIONS=false on the rest,
    # which this module does not model -- see the note in main_app.tf.
    replicas = optional(number, 1)

    # Holds the native embedding model's cache and the RAG scratch space, both
    # of which are read on every start, so they stay on cluster storage.
    storage_size = optional(string, "5Gi")

    # Uploaded files go to the NAS instead. This is a request against an SMB
    # share that is not really sized by it -- the CSI driver provisions a
    # subdirectory, not a quota -- so it is only a floor.
    uploads_storage_size = optional(string, "50Gi")

    # Sized for `replicas`; bump both together. The operator fronts the CR with
    # a Service of the same name, so the URL in locals.tf does not change.
    cache_replicas = optional(number, 1)

    # CNPG serves TLS with a private CA. "require" encrypts without verifying
    # it, which is what psycopg does here; the app strips sslmode out of the
    # URL and passes it through as a libpq connect arg.
    db_ssl_mode = optional(string, "require")

    # The async engine opens a pool per process. Left unset the app falls back
    # to a plain pool with SQLAlchemy defaults (5/10), which is thin for an app
    # that holds a connection open for the length of a streamed completion.
    database_pool_size         = optional(number, 15)
    database_pool_max_overflow = optional(number, 20)

    # Preselected model for a new chat. Addressed through Bifrost, so the name
    # carries the provider prefix its config.json declares:
    # "lemonade/<model id from Lemonade's /v1/models>". Empty offers whatever
    # Bifrost lists without picking one -- unlike AnythingLLM, which had to be
    # pinned to a single model.
    default_model = optional(string, "")

    # Empty is Open WebUI's built-in SentenceTransformers path: embeddings run
    # in-process on the CPU, so a bulk document upload cannot contend with chat
    # for the GPU, and the vectors stay independent of whatever Lemonade is
    # serving. It costs ~500MB of RSS per pod and a one-time model download
    # onto the data volume. Set "openai" to push embeddings through Bifrost
    # instead; re-embedding existing documents is required either way when this
    # changes.
    embedding_engine = optional(string, "")
    embedding_model  = optional(string, "sentence-transformers/all-MiniLM-L6-v2")

    # Width of the pgvector column created on first use. It is a ceiling, not a
    # requirement -- the 384-dim default embedding model fits fine -- but it is
    # baked into the table at creation, so raising it later means dropping the
    # collections. Above 2000 pgvector's `vector` type gives out and halfvec is
    # required, which this does not enable.
    pgvector_max_vector_length = optional(number, 1536)
  })
}
