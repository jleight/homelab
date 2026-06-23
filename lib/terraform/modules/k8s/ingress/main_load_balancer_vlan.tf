# Node-VLAN load balancer infrastructure.
#
# Load balancer VIPs that the BGP pool advertises (10.x) are routable but get
# NAT'd by the router on port-forward, losing the client IP. Instead, VIPs are
# carved from the node VLAN (192.168.3.240/28) and announced over L2 (ARP): the
# router sees directly-connected hosts and does pure DNAT, so the client IP
# survives. Combined with externalTrafficPolicy: Local (via the cilium-vlan
# GatewayClass), the real source IP reaches the backend.
#
# This file defines the shared pieces — the GatewayClass, the pool, and the L2
# announcement policy. Individual LoadBalancers opt in by using the cilium-vlan
# class (gateways) or the lb-pool=vlan label (plain Services); see public-lb and
# private-lb in main_load_balancer.tf and the mqtt/rtl LAN VIPs.

locals {
  # Gate the node-VLAN stack on IPAM defining a load-balancer block.
  vlan_lb_enabled = local.load_balancer_enabled && try(module.ipam.load_balancers.v4_cidr, null) != null

  # Pinned VIPs — the whole /28 layout in one place. Both gateways are pinned
  # (LB-IPAM doesn't guarantee which free IP an unpinned service gets), so the
  # addresses are declared, predictable, and stable across recreation. .240/.255
  # are the block's reserved network/broadcast, so usable from .241.
  vlan_lb_ips = local.vlan_lb_enabled ? {
    public  = cidrhost(module.ipam.load_balancers.v4_cidr, 1)
    private = cidrhost(module.ipam.load_balancers.v4_cidr, 2)
  } : {}
}

# externalTrafficPolicy is only configurable per-GatewayClass (it comes from the
# generated Service spec), so the node-VLAN gateway needs its own class. A custom
# class is fine — Cilium matches on controllerName, not the class name — and it
# keeps Local scoped to this gateway, away from the BGP gateways.
resource "kubectl_manifest" "load_balancer_vlan_class_config" {
  count = local.vlan_lb_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumGatewayClassConfig"

    metadata = {
      namespace = local.load_balancer_namespace
      name      = "vlan"
    }

    spec = {
      service = {
        externalTrafficPolicy = "Local"
        ipFamilies            = ["IPv4"]
      }
    }
  })
}

resource "kubectl_manifest" "load_balancer_vlan_class" {
  count = local.vlan_lb_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"

    metadata = {
      name = "cilium-vlan"
    }

    spec = {
      controllerName = "io.cilium/gateway-controller"
      parametersRef = {
        group     = "cilium.io"
        kind      = "CiliumGatewayClassConfig"
        name      = "vlan"
        namespace = local.load_balancer_namespace
      }
    }
  })
}

# The (only) load balancer pool. The serviceSelector matches the same
# lb-pool=vlan label the L2 announcement policy uses, so a LoadBalancer Service
# opts into both an IP from this range and L2 announcement with one label.
resource "kubectl_manifest" "load_balancer_vlan_pool" {
  count = local.vlan_lb_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumLoadBalancerIPPool"

    metadata = {
      name = "vlan"
    }

    spec = {
      blocks = [
        {
          start = cidrhost(module.ipam.load_balancers.v4_cidr, 0)
          stop  = cidrhost(module.ipam.load_balancers.v4_cidr, -1)
        }
      ]

      serviceSelector = {
        matchLabels = {
          "lb-pool" = "vlan"
        }
      }
    }
  })
}

# Announce the node-VLAN pool's VIPs via ARP. One node wins the lease and answers
# ARP, so traffic lands on it directly (no routing, no SNAT).
#
# No `interfaces` filter on purpose: Cilium then answers ARP on whichever device
# the request arrives on — which is the node-VLAN subinterface (enp1s0.3) where
# 192.168.3.0/24 lives. Pinning a device name here is brittle (the data path is a
# tagged VLAN subinterface, not the value in global.hcl's network.interface), and
# getting it wrong silently breaks announcement (the node holds the lease but
# replies to ARP on nothing).
resource "kubectl_manifest" "load_balancer_vlan_l2" {
  count = local.vlan_lb_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"

    metadata = {
      name = "vlan"
    }

    spec = {
      serviceSelector = {
        matchLabels = {
          "lb-pool" = "vlan"
        }
      }
      loadBalancerIPs = true
    }
  })
}
