resource "cloudflare_dns_record" "this" {
  for_each = local.enabled ? var.k8s_cluster.nodes : {}

  zone_id = local.dns_zone_id

  name    = var.k8s_cluster.subdomain
  comment = "Kubernetes cluster node (${local.environment}, ${each.key}). Managed by Terraform."

  type    = "A"
  content = cidrhost(module.ipam.pool, each.value.ip_offset)
  ttl     = 1
  proxied = false
}
