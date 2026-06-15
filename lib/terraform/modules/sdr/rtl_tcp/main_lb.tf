# Raw TCP exposed on a private LAN VIP for off-cluster clients (the iOS rtl_tcp
# app). Lives outside the Gateway API because Cilium's gateway controller
# doesn't implement TCPRoute; Cilium LB-IPAM allocates an IP from the same pool
# as the gateways, BGP-advertised to the LAN (reachable over Tailscale when away,
# no router port-forward). Mirrors the MQTT LAN VIP pattern.
resource "kubernetes_service_v1" "lb" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.name}-lb"

    labels = module.app.labels

    # external-dns watches LoadBalancer Services (service source) and creates a
    # Cloudflare A record for this hostname pointing at the assigned VIP. Records
    # a private LAN IP, so it's DNS-only (unproxied) and resolves on the LAN /
    # over Tailscale.
    annotations = {
      "external-dns.alpha.kubernetes.io/hostname" = local.hostname
    }
  }

  spec {
    type     = "LoadBalancer"
    selector = module.app.match_labels

    port {
      name        = "rtl-tcp"
      port        = local.port
      target_port = local.port
      protocol    = "TCP"
    }
  }
}
