locals {
  terraform_vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null

  cloudflare_api_token = local.enabled ? data.onepassword_item.cloudflare_api_token[0].credential : null

  dns_zone_id   = local.enabled ? one(data.cloudflare_zones.cluster[0].result).id : null
  dns_zone_name = local.enabled ? one(data.cloudflare_zones.cluster[0].result).name : null

  cluster_ip       = local.enabled ? cidrhost(var.network_subnet, var.k8s_cluster.ip_offset) : null
  cluster_dns_name = local.enabled ? "${var.k8s_cluster.subdomain}.${local.dns_zone_name}" : null

  talos_endpoint      = local.enabled ? "https://${local.cluster_dns_name}:6443" : null
  talos_secrets       = local.enabled ? talos_machine_secrets.this[0].machine_secrets : null
  talos_client_config = local.enabled ? talos_machine_secrets.this[0].client_configuration : null
  talos_cp_config     = local.enabled ? data.talos_machine_configuration.control_plane[0].machine_configuration : null

  node_ips = local.enabled ? {
    for k, v in var.k8s_cluster.nodes : k => [
      for i in split(",", data.external.node_ip[k].result.ips) : i if i != local.cluster_ip
    ][0]
  } : {}

  kubeconfig_file = local.enabled ? "${var.dot_kube_directory}/${module.this.id}" : null
  kubeconfig      = local.enabled ? talos_cluster_kubeconfig.this[0].kubeconfig_raw : null
}
