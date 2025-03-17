resource "cloudflare_dns_record" "a" {
  for_each = local.node_ips.v4

  zone_id = local.dns_zone_id

  name    = var.k8s_cluster.subdomain
  comment = "Kubernetes cluster node (${local.environment}, ${each.key}). Managed by Terraform."

  type    = "A"
  content = each.value
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "aaaa" {
  for_each = local.node_ips.v6_pd

  zone_id = local.dns_zone_id

  name    = var.k8s_cluster.subdomain
  comment = "Kubernetes cluster node (${local.environment}, ${each.key}). Managed by Terraform."

  type    = "AAAA"
  content = each.value
  ttl     = 1
  proxied = false
}
