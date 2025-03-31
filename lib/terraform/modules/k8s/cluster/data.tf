data "cloudflare_zones" "cluster" {
  count = local.enabled ? 1 : 0

  name = var.k8s_cluster.domain
}

module "ipam" {
  source = "../../_registry/ipam"

  environment = var.environment
}

module "slaac_pd" {
  for_each = var.k8s_cluster.nodes
  source   = "../../_registry/slaac"

  prefix      = module.ipam.lan.v6_prefix
  mac_address = each.value.mac_address
}
