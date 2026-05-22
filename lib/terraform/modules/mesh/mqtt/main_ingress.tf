# Forward `mqtt.mesh.<domain>` traffic from the public LB's per-host HTTPS
# listener to VerneMQ's WS listener. Envoy auto-handles the WebSocket upgrade.
resource "kubectl_manifest" "http_route" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = local.namespace
      name      = local.vernemq_name
    }

    spec = {
      parentRefs = [
        for l in var.mqtt_gateway_listeners : {
          namespace   = var.gateway_namespace
          name        = var.gateway_name
          sectionName = l.section
        }
      ]
      hostnames = local.public_hostnames
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]
          # VerneMQ's Cowboy router only dispatches WS upgrades on `/mqtt`,
          # but meshcoretomqtt (and most other clients) hardcode `/`. Rewrite
          # the path here so the upgrade lands where VerneMQ expects.
          filters = [
            {
              type = "URLRewrite"
              urlRewrite = {
                path = {
                  type            = "ReplaceFullPath"
                  replaceFullPath = "/mqtt"
                }
              }
            }
          ]
          backendRefs = [
            {
              name = local.vernemq_name
              port = local.vernemq_ws_port
            }
          ]
        }
      ]
    }
  })

  depends_on = [helm_release.this]
}

# Plain MQTT TCP exposed via a private LAN VIP — for clients (Home
# Assistant, IoT devices) that don't speak MQTT-over-WSS. JWT auth still
# applies; the auth webhook runs on every CONNECT regardless of which
# listener the client arrived on.
#
# This lives outside the Gateway API because Cilium's gateway controller
# doesn't implement TCPRoute. Cilium LB-IPAM allocates a fresh IP from the
# same pool as the gateways; the IP is BGP-advertised to the LAN but has no
# router port-forward, so it's reachable only on the home network.
resource "kubernetes_service_v1" "mqtt_lb" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.vernemq_name}-lb"

    labels = local.labels
  }

  spec {
    type = "LoadBalancer"

    # Selectors match the chart's pod labels, not local.vernemq_name — the
    # chart's `app.kubernetes.io/name` is always the chart name, only the
    # `instance` label tracks the release name.
    selector = {
      "app.kubernetes.io/name"     = var.mqtt.chart
      "app.kubernetes.io/instance" = local.vernemq_name
    }

    port {
      name        = "mqtt"
      port        = local.vernemq_mqtt_port
      target_port = local.vernemq_mqtt_port
      protocol    = "TCP"
    }
  }
}
