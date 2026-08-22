locals {
  endpoint         = "${var.k8s_cluster.subdomain}.${var.k8s_cluster.domain}"
  cluster_endpoint = "https://${local.endpoint}:6443"

  nodes = local.enabled ? {
    for k, v in var.k8s_cluster.nodes : k => v if v.enabled
  } : {}

  node_images = local.enabled ? {
    for k, v in local.nodes : k => format(
      "factory.talos.dev/installer/%s:v%s",
      v.schematic_id,
      v.talos_version
    )
  } : {}

  node_ips = {
    v4 = local.enabled ? {
      for k, v in var.k8s_cluster.nodes : k => cidrhost(module.ipam.nodes.v4_cidr, v.ipv4_offset)
    } : {}
    v6_pd = local.enabled ? {
      for k, v in var.k8s_cluster.nodes : k => module.slaac_pd[k].ip
    } : {}
  }

  feature_gates = {}

  # Splat `id` off the results rather than `one(result).id`: collapsing the whole
  # object pulls every attribute into the derived value, including the deprecated
  # `permissions`, which OpenTofu then flags on each consumer. Projecting the one
  # attribute we want never touches it. `one()` still enforces a single match.
  zone_id = try(one(data.cloudflare_zones.cluster[0].result[*].id), null)
}
