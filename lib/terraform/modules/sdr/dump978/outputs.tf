# In-cluster raw UAT endpoint. Threaded to tar1090 (as a uat_in net connector)
# via Terragrunt so it never hardcodes the service DNS.
output "service_host" {
  description = "In-cluster DNS name of the dump978 ClusterIP service."
  value       = local.enabled ? "${module.app.service_name}.${var.namespace}.svc.cluster.local" : null
}

output "uat_port" {
  description = "Port dump978 serves the raw UAT (uat_in) stream on."
  value       = local.uat_port
}

output "json_port" {
  description = "Port dump978 serves decoded UAT JSON on."
  value       = local.json_port
}
