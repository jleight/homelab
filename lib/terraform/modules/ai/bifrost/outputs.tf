output "url" {
  description = "Public URL of the gateway."
  value       = local.enabled ? "https://${local.hostname}" : null
}

output "openai_base_url" {
  description = "OpenAI-compatible base URL for harnesses."
  value       = local.enabled ? "https://${local.hostname}/v1" : null
}

output "internal_openai_base_url" {
  description = "Cluster-internal OpenAI-compatible base URL for in-cluster callers."
  value       = local.enabled ? "http://${module.app.service_name}.${var.namespace}.svc.cluster.local:8080/v1" : null
}
