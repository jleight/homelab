variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the app storage volume."
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
  default     = "anythingllm"
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

variable "anything_llm" {
  description = "AnythingLLM configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "llms")
    path      = optional(string, "/")

    # Whether to attach an HTTPRoute to the public gateway. Set false to keep
    # the app ClusterIP-only and reach it over a port-forward.
    public = optional(bool, true)

    storage_size = optional(string, "5Gi")

    # Prisma and node-postgres both talk to CNPG over TLS with a private CA.
    # "require" encrypts without verifying the CA, which is what both clients
    # do by default here. Drop to "disable" if either rejects the certificate.
    db_ssl_mode = optional(string, "require")

    # Addressed through Bifrost, so the name carries the provider prefix its
    # config.json declares: "lemonade/<model id from Lemonade's /v1/models>".
    model = optional(string, "lemonade/Qwen3.8-27B-GGUF-UD-Q8_K_XL")

    # Well under the model's real 262k window. This is the budget AnythingLLM
    # packs retrieved chunks and history into, and a local model slows down
    # sharply as the prompt grows.
    model_token_limit = optional(number, 32768)

    # Embeddings run in-process rather than through Bifrost. Lemonade can hold
    # several models resident at once, so this is not about avoiding a model
    # swap -- it keeps document ingestion off the GPU entirely, so a bulk
    # upload cannot slow down chat, and it leaves the embedding vectors
    # independent of whatever Lemonade happens to be serving. Switch to
    # "lemonade" (with a matching embedding_model) to use the GPU instead;
    # re-embedding existing documents is required either way when this changes.
    embedding_engine = optional(string, "native")
    embedding_model  = optional(string, "Xenova/all-MiniLM-L6-v2")
  })
}
