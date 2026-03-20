resource "talos_machine_secrets" "this" {
  count = local.enabled ? 1 : 0
}

data "talos_machine_configuration" "control_plane" {
  count = local.enabled ? 1 : 0

  cluster_name     = "${local.stack}-${local.component}-${local.environment}"
  cluster_endpoint = local.cluster_endpoint

  machine_secrets = try(talos_machine_secrets.this[0].machine_secrets, null)
  machine_type    = "controlplane"

  kubernetes_version = var.k8s_version
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each = local.nodes

  client_configuration = try(talos_machine_secrets.this[0].client_configuration, null)
  node                 = local.node_ips.v6_pd[each.key]

  machine_configuration_input = try(data.talos_machine_configuration.control_plane[0].machine_configuration, null)
  config_patches              = local.config_patches[each.key]

  apply_mode = "staged_if_needing_reboot"
}

resource "talos_machine_bootstrap" "this" {
  count = local.enabled ? 1 : 0

  client_configuration = try(talos_machine_secrets.this[0].client_configuration, null)
  endpoint             = local.endpoint
  node                 = values(local.node_ips.v6_pd)[0]

  depends_on = [talos_machine_configuration_apply.control_plane]
}
