locals {
  endpoint         = "${var.k8s_cluster.subdomain}.${var.k8s_cluster.domain}"
  cluster_endpoint = "https://${local.endpoint}:6443"

  nodes = local.enabled ? {
    for k, v in var.k8s_cluster.nodes : k => v if v.enabled
  } : {}

  node_ips = {
    v4 = local.enabled ? {
      for k, v in var.k8s_cluster.nodes : k => cidrhost(module.ipam.nodes.v4_cidr, v.ipv4_offset)
    } : {}
    v6_pd = local.enabled ? {
      for k, v in var.k8s_cluster.nodes : k => module.slaac_pd[k].ip
    } : {}
  }
}
