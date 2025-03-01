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
  for_each = local.enabled ? var.k8s_cluster.nodes : {}

  client_configuration = local.talos_client_config
  node                 = local.enabled ? local.node_ips[each.key] : null

  machine_configuration_input = local.talos_cp_config

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = each.value.disk
        }
        network = {
          hostname = each.key
          interfaces = [
            {
              interface = each.value.network_interface
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
        network = {
          cni = var.k8s_cluster.cilium == null ? {} : {
            name = "none"
          }
        }
        proxy = {
          disabled = var.k8s_cluster.cilium != null && var.k8s_cluster.cilium.replace_proxy
        }
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
