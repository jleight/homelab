locals {
  bgp_enabled = local.enabled && var.k8s_ingress.load_balancer.bgp_asn > 0
}

resource "kubectl_manifest" "bgp_cluster_config" {
  count = local.bgp_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumBGPClusterConfig"

    metadata = {
      name = "bgp"
    }

    spec = {
      nodeSelector = {
        "kubernetes.io/os" = "linux"
      }
      bgpInstances = [
        {
          name     = "cilium"
          localASN = var.k8s_ingress.load_balancer.bgp_asn
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
}

resource "kubectl_manifest" "bgp_peer_config" {
  count = local.bgp_enabled ? 1 : 0

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
}

resource "kubectl_manifest" "bgp_advertisement" {
  count = local.bgp_enabled ? 1 : 0

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
}
