resource "talos_machine_secrets" "this" {
  count = local.enabled ? 1 : 0
}

data "talos_machine_configuration" "control_plane" {
  count = local.enabled ? 1 : 0

  cluster_name     = module.this.id
  cluster_endpoint = local.cluster_endpoint

  machine_secrets = local.machine_secrets
  machine_type    = "controlplane"
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each = local.nodes

  client_configuration = local.client_config
  node                 = local.node_ips.v6_pd[each.key]

  machine_configuration_input = local.cp_config

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = each.value.install_disk
        }
        sysctls = {
          "user.max_user_namespaces" = "11255"
          "vm.nr_hugepages"          = "1024"
        }
        network = {
          hostname = each.value.name
          interfaces = [
            {
              interface = each.value.network_interface
              addresses = [
                "${local.node_ips.v4[each.key]}/24",
                "${local.node_ips.v6_pd[each.key]}/64",
                "${local.node_ips.v6_ll[each.key]}/64"
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
          extraArgs = merge(
            {},
            try(var.k8s_cluster.kubelet_cert_approver.version, null) != null ? {
              "rotate-server-certificates" = true
            } : {}
          )
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
            }
          ]
        }
        nodeLabels = {
          "openebs.io/engine" : "mayastor"
        }
      }
      cluster = {
        allowSchedulingOnControlPlanes = true
        network = var.k8s_cluster.cilium == null ? {} : {
          cni = {
            name = "none"
          }
        }
        proxy = {
          disabled = try(var.k8s_cluster.cilium.replace_proxy, false)
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
          admissionControl = [
            {
              name = "PodSecurity"
              configuration = {
                apiVersion = "pod-security.admission.config.k8s.io/v1beta1"
                kind       = "PodSecurityConfiguration"
                exemptions = {
                  namespaces = setunion(
                    [],
                    var.k8s_cluster.openebs != null ? [
                      var.k8s_cluster.openebs.namespace
                    ] : []
                  )
                }
              }
            }
          ]
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

  client_configuration = local.client_config
  endpoint             = local.endpoint
  node                 = values(local.node_ips.v6_pd)[0]

  depends_on = [talos_machine_configuration_apply.control_plane]
}
