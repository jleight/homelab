locals {
  config_files = local.enabled ? merge(
    {
      ".kubeconfig"  = talos_cluster_kubeconfig.this[0].kubeconfig_raw
      ".talosconfig" = data.talos_client_configuration.this[0].talos_config
    },
    {
      for k, v in var.k8s_cluster.nodes : "${k}.yaml" => (
        talos_machine_configuration_apply.control_plane[k].machine_configuration
      )
    }
  ) : {}
}

data "talos_client_configuration" "this" {
  count = local.enabled ? 1 : 0

  cluster_name         = module.this.id
  client_configuration = local.talos_client_config

  endpoints = [local.talos_endpoint]
  nodes     = values(local.node_ips)
}

resource "talos_cluster_kubeconfig" "this" {
  count = local.enabled ? 1 : 0

  client_configuration = local.talos_client_config
  node                 = local.enabled ? values(local.node_ips)[0] : null

  depends_on = [talos_machine_bootstrap.this]
}

resource "local_sensitive_file" "config" {
  for_each = local.config_files

  filename = "${var.env_directory}/${local.environment}/${each.key}"
  content  = each.value
}
