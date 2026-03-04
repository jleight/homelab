output "namespace" {
  description = "The namespace of the deployment."
  value       = var.namespace
}

output "name" {
  description = "The resolved name of the application."
  value       = local.name
}

output "labels" {
  description = "The computed Kubernetes labels."
  value       = local.labels
}

output "match_labels" {
  description = "The computed match labels (for selectors)."
  value       = local.match_labels
}

output "service_name" {
  description = "The name of the created Service."
  value       = local.service_name
}

output "service_account_name" {
  description = "The name of the created ServiceAccount."
  value       = local.service_account_name
}

output "hostname" {
  description = "The computed ingress hostname."
  value       = local.hostname
}

output "url" {
  description = "The full URL for the app (https://hostname/path)."
  value       = local.hostname != null ? "https://${local.hostname}${var.path}" : null
}

output "port" {
  description = "The primary container port."
  value       = var.port
}

output "pvc_names" {
  description = "Map of PVC key to the created PVC name."
  value = {
    for k, v in kubernetes_persistent_volume_claim_v1.this : k => v.metadata[0].name
  }
}

output "postgres_username" {
  description = "The generated database username."
  value       = local.postgres_username
}

output "postgres_password" {
  description = "The generated database password."
  value       = local.postgres_password
  sensitive   = true
}

output "postgres_secret_name" {
  description = "The name of the Kubernetes secret containing database credentials."
  value       = local.postgres_secret_name
}

output "postgres_host" {
  description = "The in-cluster hostname for the read-write endpoint."
  value       = local.postgres_host
}

output "postgres_port" {
  description = "The database port."
  value       = var.postgres_enabled ? 5432 : null
}

output "postgres_url" {
  description = "A full postgres:// connection URL."
  value       = local.enabled && var.postgres_enabled ? "postgres://${local.postgres_username}:${local.postgres_password}@${local.postgres_host}/app" : null
  sensitive   = true
}
