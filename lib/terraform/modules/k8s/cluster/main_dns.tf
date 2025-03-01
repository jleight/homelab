resource "cloudflare_dns_record" "this" {
  count = local.enabled ? 1 : 0

  zone_id = local.leighthaus_zone_id

  name    = var.k8s_cluster_subdomain
  comment = "Kubernetes cluster endpoint (${local.environment}). Managed by Terraform."

  type    = "A"
  content = local.cluster_ip
  ttl     = 1
  proxied = false
}
