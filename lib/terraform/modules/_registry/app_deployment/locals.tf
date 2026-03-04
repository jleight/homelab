locals {
  name  = coalesce(var.name, local.component)
  image = "${var.image}:${var.image_version}"

  match_labels = {
    "app.kubernetes.io/name"     = local.name
    "app.kubernetes.io/instance" = local.name
  }

  labels = merge(
    local.match_labels,
    {
      "app.kubernetes.io/version"    = var.image_version
      "app.kubernetes.io/component"  = coalesce(var.app_component, local.name)
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  hostname = var.subdomain != null && var.gateway_domain != null ? (
    "${var.subdomain}.${var.gateway_domain}"
  ) : null

  service_account_name = local.enabled ? kubernetes_service_account_v1.this[0].metadata[0].name : null
  service_name         = local.enabled ? kubernetes_service_v1.this[0].metadata[0].name : null

  postgres_username    = local.enabled && var.postgres_enabled ? random_pet.postgres_username[0].id : null
  postgres_password    = local.enabled && var.postgres_enabled ? random_password.postgres_password[0].result : null
  postgres_secret_name = local.enabled && var.postgres_enabled ? kubernetes_secret_v1.postgres[0].metadata[0].name : null
  postgres_host        = var.postgres_enabled ? "${local.name}-db-rw.${var.namespace}.svc.cluster.local" : null
  postgres_url         = var.postgres_enabled ? "postgres://${local.postgres_username}:${local.postgres_password}@${local.postgres_host}/app" : null

  postgres_field_values = {
    host     = local.postgres_host
    port     = var.postgres_enabled ? "5432" : null
    username = local.postgres_username
    database = var.postgres_database
  }

  postgres_env = {
    for env_name, field in var.postgres_env_vars : env_name => local.postgres_field_values[field]
  }
}
