output "url" {
  description = "URL of the SearXNG UI, on whichever gateway gateway_refs points at."
  value       = local.enabled ? local.public_url : null
}

output "internal_url" {
  description = "Cluster-internal base URL for the SearXNG instance."
  value       = local.enabled ? local.internal_url : null
}

output "internal_search_url" {
  description = "Cluster-internal search endpoint, for callers that want the API directly."
  value       = local.enabled ? "${local.internal_url}/search" : null
}

output "service_name" {
  description = "Name of the ClusterIP Service (for port-forwarding)."
  value       = module.app.service_name
}
