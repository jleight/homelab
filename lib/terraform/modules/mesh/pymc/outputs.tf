output "namespace" {
  description = "The namespace the app is deployed into."
  value       = local.namespace
}

output "service_name" {
  description = "The name of the created Service."
  value       = local.enabled ? kubernetes_service_v1.this[0].metadata[0].name : null
}

output "hostname" {
  description = "The ingress hostname for the web UI."
  value       = local.hostname
}

output "companion_ports" {
  description = "Map of companion name to its TCP port on the companions LoadBalancer."
  value       = local.companion_ports
}

output "companions_lb_ip" {
  description = "VIP allocated to the companions LoadBalancer — the Tailscale IP when companions_tailscale is set, else the Cilium LAN VIP. Clients connect here on each companion's port."
  value       = try(kubernetes_service_v1.companions_lb[0].status[0].load_balancer[0].ingress[0].ip, null)
}

output "companions_lb_hostname" {
  description = "MagicDNS name of the companions tailnet device (only populated when companions_tailscale is set)."
  value       = try(kubernetes_service_v1.companions_lb[0].status[0].load_balancer[0].ingress[0].hostname, null)
}
