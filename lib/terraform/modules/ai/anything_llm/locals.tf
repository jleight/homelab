locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name     = local.component
  hostname = "${var.anything_llm.subdomain}.${var.gateway_domain}"

  vault_uuid      = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  bifrost_api_key = local.enabled ? data.onepassword_item.bifrost[0].credential : null

  password = local.enabled ? random_password.password[0].result : null

  # Both connection strings point at the same database. The `pg` image keeps
  # application data there via Prisma (DATABASE_URL) and its vectors there via
  # pgvector (PGVECTOR_CONNECTION_STRING). The db module generates this password
  # with special = false, so it needs no URL escaping.
  database_url = "postgresql://${var.db_username}:${var.db_password}@${var.db_host}:${var.db_port}/${var.db_name}?sslmode=${var.anything_llm.db_ssl_mode}"

  secret_name = local.enabled ? kubernetes_secret_v1.this[0].metadata[0].name : null
}
