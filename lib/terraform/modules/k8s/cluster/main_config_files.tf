locals {
  config_files = local.enabled ? merge(
    {
      ".kubeconfig"  = talos_cluster_kubeconfig.this[0].kubeconfig_raw
      ".talosconfig" = data.talos_client_configuration.this[0].talos_config
    },
    {
      for k, v in local.nodes : "${k}.yaml" => (
        talos_machine_configuration_apply.control_plane[k].machine_configuration
      )
    }
  ) : {}
}

data "talos_client_configuration" "this" {
  count = local.enabled ? 1 : 0

  cluster_name         = module.this.id
  client_configuration = local.client_config

  endpoints = [local.endpoint]
  nodes     = values(local.node_ips.v6_pd)
}

resource "talos_cluster_kubeconfig" "this" {
  count = local.enabled ? 1 : 0

  client_configuration = local.client_config
  node                 = values(local.node_ips.v6_pd)[0]
}

resource "local_sensitive_file" "config" {
  for_each = local.config_files

  filename = "${var.env_directory}/${local.environment}/${each.key}"
  content  = each.value
}
