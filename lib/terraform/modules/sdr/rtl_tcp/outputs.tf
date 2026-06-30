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

output "tailscale_hostname" {
  description = "MagicDNS name of the rtl_tcp tailnet device (only populated when tailscale is set)."
  value       = local.enabled ? try(kubernetes_service_v1.lb[0].status[0].load_balancer[0].ingress[0].hostname, null) : null
}

output "lb_ip" {
  description = "VIP allocated to the rtl_tcp LoadBalancer — the Tailscale IP when tailscale is set, else the Cilium LAN VIP."
  value       = local.enabled ? try(kubernetes_service_v1.lb[0].status[0].load_balancer[0].ingress[0].ip, null) : null
}
