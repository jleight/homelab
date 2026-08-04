# In-cluster API endpoint. Threaded to any other in-cluster consumer via
# Terragrunt so it never hardcodes the service DNS.
output "host" {
  description = "In-cluster DNS name of the beacon-server ClusterIP service (REST API, WebSocket at /ws)."
  value       = local.enabled ? "${module.server.service_name}.${var.namespace}.svc.cluster.local" : null
}

output "port" {
  description = "Port the beacon-server Service listens on."
  value       = 80
}

output "hostname" {
  description = "Hostname the frontend (and, same-origin, the API) is served on."
  value       = local.enabled ? local.hostname : null
}

output "url" {
  description = "URL of the Beacon frontend."
  value       = local.enabled ? module.web.url : null
}
