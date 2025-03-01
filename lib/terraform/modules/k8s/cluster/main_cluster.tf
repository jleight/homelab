resource "talos_machine_secrets" "this" {
  count = local.enabled ? 1 : 0
}

data "talos_machine_configuration" "control_plane" {
  count = local.enabled ? 1 : 0

  cluster_name     = module.this.id
  cluster_endpoint = local.talos_endpoint
  machine_secrets  = local.talos_secrets
  machine_type     = "controlplane"
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each = local.enabled ? var.k8s_cluster_nodes : {}

  node                        = local.enabled ? local.node_ips[each.key] : null
  client_configuration        = local.talos_client_config
  machine_configuration_input = local.talos_cp_config

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/vda"
        }
        network = {
          hostname = each.key
          interfaces = [
            {
              interface = "ens2"
              dhcp      = true
              vip = {
                ip = local.cluster_ip
              }
            }
          ]
        }
        certSANs = [local.cluster_dns_name]
      }
      cluster = {
        allowSchedulingOnControlPlanes = true
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  count = local.enabled ? 1 : 0

  client_configuration = local.talos_client_config
  node                 = local.enabled ? values(local.node_ips)[0] : null

  depends_on = [talos_machine_configuration_apply.control_plane]
}
