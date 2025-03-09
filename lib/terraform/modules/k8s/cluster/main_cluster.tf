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
  for_each = local.enabled ? var.k8s_cluster.nodes : {}

  client_configuration = local.client_config
  node                 = local.enabled ? local.node_ips[each.key] : null

  machine_configuration_input = local.cp_config

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = each.value.install_disk
        }
        sysctls = {
          "vm.nr_hugepages" = "1024"
        }
        network = {
          hostname = each.value.name
          interfaces = [
            {
              interface = each.value.network_interface
              addresses = [cidrhost(module.ipam.pool, each.value.ip_offset)]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = cidrhost(var.network.subnet, var.network.ip_offsets.gateway)
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
  node                 = local.enabled ? values(local.node_ips)[0] : null

  depends_on = [talos_machine_configuration_apply.control_plane]
}
