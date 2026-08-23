output "url" {
  description = "URL of the AnythingLLM UI. Null when it is not publicly routed."
  value       = local.enabled && var.anything_llm.public ? "https://${local.hostname}" : null
}

output "service_name" {
  description = "Name of the ClusterIP Service (for port-forwarding)."
  value       = module.app.service_name
}
