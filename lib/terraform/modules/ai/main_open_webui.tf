resource "random_password" "open_webui_admin" {
  length  = 32
  special = false
}

resource "onepassword_item" "open_webui" {
  title    = "Open WebUI"
  category = "login"
  vault    = data.onepassword_vault.terraform.uuid

  username = var.open_webui.admin_email
  password = random_password.open_webui_admin.result
  url      = "https://${local.open_webui_domain}"
}

resource "random_password" "open_webui_secret_key" {
  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "open_webui" {
  metadata {
    namespace = module.namespace.name
    name      = "open-webui"
  }

  data = {
    DATABASE_URL         = local.open_webui_database_url
    PGVECTOR_DB_URL      = local.open_webui_database_url
    OPENAI_API_KEY       = var.lemonade.api_key
    RAG_OPENAI_API_KEY   = var.lemonade.api_key
    WEBUI_SECRET_KEY     = random_password.open_webui_secret_key.result
    WEBUI_ADMIN_PASSWORD = random_password.open_webui_admin.result
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "open_webui_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "open-webui-subst"
  }

  data = {
    gateway_parent_refs   = jsonencode(var.open_webui.gateway_refs)
    domain                = local.open_webui_domain
    data_storage_class    = var.open_webui.data_storage_class
    uploads_storage_class = var.open_webui.uploads_storage_class
    secret_checksum       = "sha256:${sha256(jsonencode(kubernetes_secret_v1.open_webui.data))}"
  }
}

resource "kubernetes_config_map_v1" "open_webui_env" {
  metadata {
    namespace = module.namespace.name
    name      = "open-webui-env"
  }

  data = {
    WEBUI_URL = "https://${local.open_webui_domain}"

    # Defaults to "*".
    CORS_ALLOW_ORIGIN = "https://${local.open_webui_domain}"

    WEBUI_ADMIN_EMAIL = var.open_webui.admin_email
    WEBUI_ADMIN_NAME  = var.open_webui.admin_name

    OPENAI_API_BASE_URL     = local.lemonade_base_url
    RAG_OPENAI_API_BASE_URL = local.lemonade_base_url

    SEARXNG_QUERY_URL = "${local.searxng_url}/search"

    REDIS_URL           = local.open_webui_redis_url
    WEBSOCKET_REDIS_URL = local.open_webui_redis_url
  }
}
