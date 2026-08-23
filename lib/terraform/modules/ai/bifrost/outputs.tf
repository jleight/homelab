output "url" {
  description = "Public URL of the gateway."
  value       = local.enabled ? "https://${local.hostname}" : null
}

output "openai_base_url" {
  description = "OpenAI-compatible base URL for harnesses."
  value       = local.enabled ? "https://${local.hostname}/v1" : null
}
