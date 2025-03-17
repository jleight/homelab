locals {
  cilium_bgp_enabled = local.cilium_enabled && try(var.k8s_cluster.cilium.bgp, false)

  router_bgp_conf = local.cilium_bgp_enabled ? join(
    "\n",
    concat(
      [
        <<-EOF
          ! -*- bgp -*-
          !
          hostname $UDMP_HOSTNAME
          password zebra
          frr defaults traditional
          log file stdout
          !
          router bgp 65000
            bgp ebgp-requires-policy
            bgp router-id ${var.network.gateway_ipv4}
            maximum-paths 4
            !
            neighbor ${module.this.id} peer-group
            neighbor ${module.this.id} remote-as 65010
            neighbor ${module.this.id} activate
            neighbor ${module.this.id} soft-reconfiguration inbound
        EOF
      ],
      [
        for k, v in var.k8s_cluster.nodes :
        "  neighbor ${cidrhost(module.ipam.cidr_v4, v.ipv4_offset)} peer-group ${module.this.id}"
      ],
      [
        <<-EOF
          address-family ipv4 unicast
            redistribute connected
            neighbor ${module.this.id} activate
            neighbor ${module.this.id} route-map ALLOW-ALL in
            neighbor ${module.this.id} route-map ALLOW-ALL out
            neighbor ${module.this.id} next-hop-self
          exit-address-family
          !
        route-map ALLOW-ALL permit 10
        !
        line vty
        !
        EOF
      ]
    )
  ) : null
}

resource "kubectl_manifest" "cilium_bgp_cluster_config" {
  count = local.cilium_bgp_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumBGPClusterConfig"

    metadata = {
      name = "cilium-bgp"
    }

    spec = {
      nodeSelector = {
        "kubernetes.io/os" = "linux"
      }
      bgpInstances = [
        {
          name     = "cilium"
          localASN = 65010
          peers = [
            {
              name        = "gateway"
              peerASN     = 65000
              peerAddress = var.network.gateway_ipv4
              peerConfigRef = {
                name = "cilium-peer"
              }
            }
          ]
        }
      ]
    }
  })

  depends_on = [helm_release.cilium]
}

resource "kubectl_manifest" "cilium_bgp_peer_config" {
  count = local.cilium_bgp_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumBGPPeerConfig"

    metadata = {
      name = "cilium-peer"
    }

    spec = {
      timers = {
        holdTimeSeconds      = 9
        keepAliveTimeSeconds = 3
      }
      ebgpMultihop = 4
      gracefulRestart = {
        enabled            = true
        restartTimeSeconds = 15
      }
      families = [
        {
          afi  = "ipv4"
          safi = "unicast"
          advertisements = {
            matchLabels = {
              advertise = "bgp"
            }
          }
        }
      ]
    }
  })

  depends_on = [helm_release.cilium]
}

resource "kubectl_manifest" "cilium_bgp_advertisement" {
  count = local.cilium_bgp_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumBGPAdvertisement"

    metadata = {
      name = "bgp-advertisements"
      labels = {
        advertise = "bgp"
      }
    }

    spec = {
      advertisements = [
        {
          advertisementType = "PodCIDR"
        },
        {
          advertisementType = "Service"
          service = {
            addresses = ["LoadBalancerIP"]
          }
          selector = {
            matchExpressions = [
              {
                key      = "io.cilium/bgp"
                operator = "NotIn"
                values   = ["false"]
              }
            ]
          }
        }
      ]
    }
  })

  depends_on = [helm_release.cilium]
}

output "router_bgp_conf" {
  value = local.router_bgp_conf
}
