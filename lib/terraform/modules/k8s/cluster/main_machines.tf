resource "talos_machine_configuration_apply" "eq14_1" {
  client_configuration = try(talos_machine_secrets.this[0].client_configuration, null)
  node                 = local.node_ips.v6_pd["eq14_1"]

  machine_configuration_input = try(data.talos_machine_configuration.control_plane[0].machine_configuration, null)
  config_patches              = local.config_patches["eq14_1"]
}

resource "talos_machine_configuration_apply" "eq14_2" {
  client_configuration = try(talos_machine_secrets.this[0].client_configuration, null)
  node                 = local.node_ips.v6_pd["eq14_2"]

  machine_configuration_input = try(data.talos_machine_configuration.control_plane[0].machine_configuration, null)
  config_patches              = local.config_patches["eq14_2"]

  depends_on = [talos_machine_configuration_apply.eq14_1]
}

resource "talos_machine_configuration_apply" "eq14_3" {
  client_configuration = try(talos_machine_secrets.this[0].client_configuration, null)
  node                 = local.node_ips.v6_pd["eq14_3"]

  machine_configuration_input = try(data.talos_machine_configuration.control_plane[0].machine_configuration, null)
  config_patches              = local.config_patches["eq14_3"]

  depends_on = [talos_machine_configuration_apply.eq14_2]
}
