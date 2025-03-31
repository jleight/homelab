resource "talos_machine_secrets" "this" {
  count = local.enabled ? 1 : 0
}

data "talos_machine_configuration" "control_plane" {
  count = local.enabled ? 1 : 0

  cluster_name     = "${local.stack}-${local.component}-${local.environment}"
  cluster_endpoint = local.cluster_endpoint

  machine_secrets = try(talos_machine_secrets.this[0].machine_secrets, null)
  machine_type    = "controlplane"
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each = local.nodes

  client_configuration = try(talos_machine_secrets.this[0].client_configuration, null)
  node                 = local.node_ips.v6_pd[each.key]

  machine_configuration_input = try(data.talos_machine_configuration.control_plane[0].machine_configuration, null)

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = each.value.install_disk
          wipe = true
          image = format(
            "factory.talos.dev/installer%s/%s:v%s",
            each.value.secure_boot ? "-secureboot" : "",
            each.value.schematic_id,
            each.value.talos_version
          )
        }
        sysctls = {
          "user.max_user_namespaces" = "11255"
        }
        disks = [
          {
            device     = each.value.storage_disk
            partitions = [{ mountpoint = "/var/mnt/storage" }]
          }
        ]
        systemDiskEncryption = each.value.secure_boot ? {
          for k in ["state", "ephemeral"] : k => {
            provider = "luks2"
            keys = [
              {
                slot = 0
                tpm  = {}
              }
            ]
          }
        } : {}
        network = {
          hostname = each.value.name
          interfaces = [
            {
              interface = each.value.network_interface
              addresses = [
                "${local.node_ips.v4[each.key]}/24",
                "${local.node_ips.v6_pd[each.key]}/64"
              ]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.network.gateway_ipv4
                },
                {
                  network = "::/0"
                  gateway = var.network.gateway_ipv6
                }
              ]
            }
          ]
          nameservers = var.network.nameservers
        }
        certSANs = [
          local.endpoint
        ]
        kubelet = {
          extraArgs = {
            "rotate-server-certificates" = true
          }
          extraConfig = {
            featureGates = {
              "UserNamespacesSupport"              = true
              "UserNamespacesPodSecurityStandards" = true
            }
          }
          extraMounts = [
            {
              type        = "bind"
              source      = "/var/local"
              destination = "/var/local"
              options     = ["bind", "rshared", "rw"]
            },
            {
              type        = "bind"
              source      = "/var/mnt/storage"
              destination = "/var/mnt/storage"
              options     = ["bind", "rshared", "rw"]
            }
          ]
        }
      }
      cluster = {
        allowSchedulingOnControlPlanes = true
        network = {
          podSubnets     = [module.ipam.resources.pods]
          serviceSubnets = [module.ipam.resources.services]
          cni            = { name = "none" }
        }
        proxy = {
          disabled = true
        }
        apiServer = {
          extraArgs = {
            "feature-gates" = join(
              ",",
              [
                "UserNamespacesSupport=true",
                "UserNamespacesPodSecurityStandards=true"
              ]
            )
          }
        }
        controllerManager = {
          extraArgs = {
            "terminated-pod-gc-threshold" = 1
          }
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  count = local.enabled ? 1 : 0

  client_configuration = try(talos_machine_secrets.this[0].client_configuration, null)
  endpoint             = local.endpoint
  node                 = values(local.node_ips.v6_pd)[0]

  depends_on = [talos_machine_configuration_apply.control_plane]
}
