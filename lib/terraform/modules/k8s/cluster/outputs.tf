output "peer_group" {
  value = local.enabled && try(var.k8s_cluster.cilium.bgp_as, 0) != 0 ? {
    name  = module.this.id
    as    = var.k8s_cluster.cilium.bgp_as
    peers = values(local.node_ips.v4)
  } : null
}
