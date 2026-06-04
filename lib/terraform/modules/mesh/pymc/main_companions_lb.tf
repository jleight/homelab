# Companions each run a TCP frame server (on distinct ports) inside the one
# repeater pod; this single Service exposes them all on one VIP, one port per
# companion. It lives outside the Gateway API because neither Cilium's gateway
# controller nor Tailscale implement TCPRoute.
#
# By default (companions_tailscale = true) the Tailscale operator handles it via
# loadBalancerClass=tailscale: the Service becomes a dedicated tailnet device with
# a stable Tailscale IP (+ MagicDNS name), reachable from anywhere on the tailnet
# — which is what the IP-only companion client needs off the home network. With
# companions_tailscale = false it falls back to a LAN-only Cilium LB-IPAM VIP.
resource "kubernetes_service_v1" "companions_lb" {
  count = local.enabled && length(var.pymc.companions) > 0 ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-companions"

    labels = local.labels

    # Tags default to tag:k8s (already owned by the operator); only the hostname
    # needs setting. Annotation is inert when not using the tailscale class.
    annotations = var.pymc.companions_tailscale ? {
      "tailscale.com/hostname" = local.companions_hostname
    } : {}
  }

  spec {
    type                = "LoadBalancer"
    load_balancer_class = var.pymc.companions_tailscale ? "tailscale" : null
    selector            = local.match_labels

    dynamic "port" {
      for_each = local.companion_ports

      content {
        name        = "c-${port.value}"
        port        = port.value
        target_port = port.value
        protocol    = "TCP"
      }
    }
  }
}
