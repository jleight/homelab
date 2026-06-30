# rtl_tcp is a raw TCP server, so it can't ride the Gateway API (neither Cilium's
# gateway controller nor Tailscale implement TCPRoute). This Service exposes it
# off-cluster directly.
#
# By default (tailscale = true) the Tailscale operator handles it via
# loadBalancerClass=tailscale: the Service becomes a dedicated tailnet device with
# a stable Tailscale IP (+ MagicDNS name), reachable from anywhere on the tailnet
# — which is what the off-LAN iOS rtl_tcp client needs. With tailscale = false it
# falls back to a LAN-only Cilium LB-IPAM VIP.
resource "kubernetes_service_v1" "lb" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.name}-lb"

    labels = module.app.labels

    # Tags default to tag:k8s (already owned by the operator); only the hostname
    # needs setting. Annotation is inert when not using the tailscale class.
    annotations = var.rtl_tcp.tailscale ? {
      "tailscale.com/hostname" = local.tailscale_hostname
    } : {}
  }

  spec {
    type                = "LoadBalancer"
    load_balancer_class = var.rtl_tcp.tailscale ? "tailscale" : null
    selector            = module.app.match_labels

    port {
      name        = "rtl-tcp"
      port        = local.port
      target_port = local.port
      protocol    = "TCP"
    }
  }
}
