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
            disks = v.storage_disk == null ? [] : [
              {
                device     = v.storage_disk
                partitions = [{ mountpoint = "/var/mnt/longhorn" }]
              }
            ]
            systemDiskEncryption = {} # deprecated
            network = {
              hostname = v.name # deprecated
              interfaces = [    # deprecated
                {
                  interface = v.network_interface
                  dhcp      = false
                  vlans = [
                    {
                      vlanId = 1
                      dhcp   = false
                    },
                    {
                      vlanId = v.vlan_id
                      addresses = [
                        "${local.node_ips.v4[k]}/24",
                        "${local.node_ips.v6_pd[k]}/64"
                      ]
                      routes = [
                        {
                          network = "0.0.0.0/0"
                          gateway = module.ipam.nodes.v4_gateway
                        },
                        {
                          network = "::/0"
                          gateway = module.ipam.nodes.v6_gateway
                        }
                      ]
                    }
                  ]
                }
              ]
              nameservers = var.network.nameservers # deprecated
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
      ] : []
    )
  }
}
