resource "cloudflare_dns_record" "a" {
  for_each = local.node_ips.v4

  zone_id = try(one(data.cloudflare_zones.cluster[0].result).id, null)

  name    = local.endpoint
  comment = "Kubernetes cluster node (${local.environment}, ${each.key}). Managed by Terraform."

  type    = "A"
  content = each.value
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "aaaa" {
  for_each = local.node_ips.v6_pd

  zone_id = try(one(data.cloudflare_zones.cluster[0].result).id, null)

  name    = local.endpoint
  comment = "Kubernetes cluster node (${local.environment}, ${each.key}). Managed by Terraform."

  type    = "AAAA"
  content = each.value
  ttl     = 1
  proxied = false
}
