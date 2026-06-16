# In-cluster Beast endpoint. Threaded to tar1090 via Terragrunt so it never
# hardcodes the service DNS.
output "service_host" {
  description = "In-cluster DNS name of the readsb Beast ClusterIP service."
  value       = local.enabled ? "${module.app.service_name}.${var.namespace}.svc.cluster.local" : null
}

output "service_port" {
  description = "Port readsb serves the Beast stream on."
  value       = local.beast_port
}
