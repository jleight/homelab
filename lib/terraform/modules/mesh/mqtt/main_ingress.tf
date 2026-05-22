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
