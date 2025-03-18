locals {
  terraform_vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null

  cloudflare_api_token = local.enabled ? data.onepassword_item.cloudflare_api_token[0].credential : null
  dns_zone_id          = local.enabled ? one(data.cloudflare_zones.cluster[0].result).id : null

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

  machine_secrets = local.enabled ? talos_machine_secrets.this[0].machine_secrets : null
  client_config   = local.enabled ? talos_machine_secrets.this[0].client_configuration : null
  cp_config       = local.enabled ? data.talos_machine_configuration.control_plane[0].machine_configuration : null
}
