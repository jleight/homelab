output "domain" {
  value = local.enabled ? var.k8s_cluster.domain : null
}

output "node_ipv4s" {
  value = local.enabled ? values(local.node_ips.v4) : []
}
