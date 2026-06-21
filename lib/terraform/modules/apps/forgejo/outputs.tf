output "url" {
  description = "Base URL of the Forgejo instance."
  value       = local.enabled ? "https://${local.hostname}" : null
}

output "admin_username" {
  description = "Username of the Forgejo admin account."
  value       = local.admin_user_username
}

output "admin_password" {
  description = "Password of the Forgejo admin account."
  value       = local.admin_user_password
  sensitive   = true
}

output "namespace" {
  description = "Namespace Forgejo runs in."
  value       = local.namespace
}

output "postgres_cluster_name" {
  description = "Name of the CloudNativePG cluster backing Forgejo."
  value       = local.enabled ? "${local.name}-db" : null
}

output "postgres_host" {
  description = "Read/write service host of the Forgejo Postgres cluster."
  value       = local.enabled ? "${local.name}-db-rw.${local.namespace}.svc.cluster.local" : null
}

output "woodpecker_database" {
  description = "Name of the dedicated database for Woodpecker CI in this cluster."
  value       = local.enabled ? local.woodpecker_database : null
}

output "woodpecker_postgres_username" {
  description = "Dedicated Postgres role for Woodpecker CI."
  value       = local.woodpecker_postgres_username
}

output "woodpecker_postgres_password" {
  description = "Password for the Woodpecker CI Postgres role."
  value       = local.woodpecker_postgres_password
  sensitive   = true
}
