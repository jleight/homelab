# In-cluster address for rtl_tcp clients (OpenWebRX, OP25). Threaded to those
# components via Terragrunt so they never hardcode the service DNS.
output "service_host" {
  description = "In-cluster DNS name of the rtl_tcp ClusterIP service."
  value       = local.enabled ? "${module.app.service_name}.${var.namespace}.svc.cluster.local" : null
}

output "service_port" {
  description = "Port the rtl_tcp server listens on."
  value       = local.port
}

output "hostname" {
  description = "LAN hostname for the rtl_tcp LoadBalancer VIP."
  value       = local.hostname
}
