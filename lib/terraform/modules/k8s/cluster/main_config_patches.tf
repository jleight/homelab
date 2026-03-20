locals {
  config_patches = {
    for k, v in local.nodes : k => concat(
      [
        yamlencode({
          machine = {
            install = {
              disk  = v.install_disk
              wipe  = true
              image = local.node_images[k]
            }
            sysctls = {
              "user.max_user_namespaces" = "11255"
              "vm.nr_hugepages"          = "1024"
            }
            kernel = {
              modules = [
                { name = "nvme_tcp" },
                { name = "vfio_pci" }
              ]
            }
            certSANs = [
              local.endpoint
            ]
            kubelet = {
              extraArgs = {
                "rotate-server-certificates" = true
              }
              extraConfig = {
                featureGates = local.feature_gates
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
                  source      = "/var/mnt/longhorn"
                  destination = "/var/mnt/longhorn"
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
                  [for k, v in local.feature_gates : "${k}=${v}"]
                )
              }
            }
            controllerManager = {
              extraArgs = {
                "terminated-pod-gc-threshold" = 1
              }
            }
          }
        }),
        yamlencode({
          apiVersion = "v1alpha1"
          kind       = "HostnameConfig"
          hostname   = v.name
          auto       = "off"
        }),
        yamlencode({
          apiVersion = "v1alpha1"
          kind       = "VLANConfig"
          name       = "${v.network_interface}.1"
          vlanID     = 1
          parent     = v.network_interface
        }),
        yamlencode({
          apiVersion = "v1alpha1"
          kind       = "VLANConfig"
          name       = "${v.network_interface}.${v.vlan_id}"
          vlanID     = v.vlan_id
          parent     = v.network_interface
          addresses = [
            { address = "${local.node_ips.v4[k]}/24" },
            { address = "${local.node_ips.v6_pd[k]}/64" }
          ]
          routes = [
            { gateway = module.ipam.nodes.v4_gateway },
            { gateway = module.ipam.nodes.v6_gateway }
          ]
        }),
        yamlencode({
          apiVersion = "v1alpha1"
          kind       = "ResolverConfig"
          nameservers = [
            for ns in var.network.nameservers : {
              address = ns
            }
          ]
        })
      ],
      v.storage_disk == null ? [
        yamlencode({
          apiVersion = "v1alpha1"
          kind       = "VolumeConfig"
          name       = "EPHEMERAL"
          provisioning = {
            diskSelector = {
              match = "system_disk"
            }
            minSize = "100MiB"
            maxSize = "40GiB"
          }
        }),
        yamlencode({
          apiVersion = "v1alpha1"
          kind       = "UserVolumeConfig"
          name       = "longhorn"
          provisioning = {
            diskSelector = {
              match = "system_disk"
            }
            minSize = "1TiB"
            maxSize = "1TiB"
          }
        })
        ] : [
        yamlencode({
          apiVersion = "v1alpha1"
          kind       = "ExistingVolumeConfig"
          name       = "longhorn"
          discovery = {
            volumeSelector = {
              match = "volume.name == \"xfs\" && disk.symlinks.exists(s, s == \"${v.storage_disk}\")"
            }
          }
        })
      ]
    )
  }
}
