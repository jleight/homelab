locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name     = local.component
  hostname = "${var.open_webui.subdomain}.${var.gateway_domain}"

  vault_uuid      = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  bifrost_api_key = local.enabled ? data.onepassword_item.bifrost[0].credential : null

  admin_password = local.enabled ? random_password.admin_password[0].result : null

  # Both connection strings point at the same database: SQLAlchemy owns the
  # application tables (DATABASE_URL) and the pgvector client owns the
  # embedding tables (PGVECTOR_DB_URL). PGVECTOR_DB_URL defaults to
  # DATABASE_URL upstream, but naming it keeps the vector store from silently
  # following a future change to the primary URL. The db module generates this
  # password with special = false, so it needs no URL escaping.
  database_url = "postgresql://${var.db_username}:${var.db_password}@${var.db_host}:${var.db_port}/${var.db_name}?sslmode=${var.open_webui.db_ssl_mode}"

  cache_name = "${local.name}-cache"
  redis_url  = "redis://${local.cache_name}.${var.namespace}.svc.cluster.local:6379/0"

  secret_name = local.enabled ? kubernetes_secret_v1.this[0].metadata[0].name : null
}
