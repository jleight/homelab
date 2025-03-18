locals {
  cilium_bgp_as      = try(var.k8s_cluster.cilium.bgp_as, 0)
  cilium_bgp_enabled = local.cilium_enabled && local.cilium_bgp_as != 0
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
          localASN = local.cilium_bgp_as
          peers = [
            {
              name        = "gateway"
              peerASN     = var.network.gateway_as
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
