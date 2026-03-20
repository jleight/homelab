locals {
  config_files = local.enabled ? {
    ".kubeconfig"  = talos_cluster_kubeconfig.this[0].kubeconfig_raw
    ".talosconfig" = data.talos_client_configuration.this[0].talos_config
    "eq14_1.yaml"  = talos_machine_configuration_apply.eq14_1.machine_configuration
    "eq14_2.yaml"  = talos_machine_configuration_apply.eq14_2.machine_configuration
    "eq14_3.yaml"  = talos_machine_configuration_apply.eq14_3.machine_configuration
  } : {}
}

data "talos_client_configuration" "this" {
  count = local.enabled ? 1 : 0

  cluster_name         = try(data.talos_machine_configuration.control_plane[0].cluster_name, null)
  client_configuration = try(talos_machine_secrets.this[0].client_configuration, null)

  endpoints = [local.endpoint]
  nodes     = values(local.node_ips.v6_pd)
}

resource "talos_cluster_kubeconfig" "this" {
  count = local.enabled ? 1 : 0

  client_configuration = try(talos_machine_secrets.this[0].client_configuration, null)
  node                 = values(local.node_ips.v6_pd)[0]
}

resource "local_sensitive_file" "config" {
  for_each = local.config_files

  filename = "${var.env_directory}/${local.environment}/${each.key}"
  content  = each.value
}
