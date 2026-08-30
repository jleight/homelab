output "url" {
  description = "URL of the Open WebUI, on whichever gateway gateway_refs points at."
  value       = local.enabled ? "https://${local.hostname}" : null
}

output "service_name" {
  description = "Name of the ClusterIP Service (for port-forwarding)."
  value       = module.app.service_name
}
