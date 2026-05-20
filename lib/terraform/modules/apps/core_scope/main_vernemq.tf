resource "random_password" "vernemq_internal" {
  count = local.enabled ? 1 : 0

  length  = 32
  special = false
}

resource "helm_release" "vernemq" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.vernemq_name
  repository = var.core_scope.vernemq.repository
  chart      = var.core_scope.vernemq.chart
  version    = var.core_scope.vernemq.version

  values = [
    yamlencode({
      fullnameOverride = local.vernemq_name

      replicaCount = 1

      # mqtt: plain TCP on 1883 for the in-cluster CoreScope subscriber.
      # ws: MQTT-over-WebSocket on 8080 — the public LB gateway terminates
      # TLS on 443 for `mqtt.mesh.leightha.us` and forwards cleartext WS
      # in-cluster to this listener.
      service = {
        type = "ClusterIP"
        mqtt = {
          enabled = true
        }
        ws = {
          enabled = true
          port    = local.vernemq_ws_port
        }
      }

      # No durable session state needed — CoreScope subscribes immediately
      # and external publishers use QoS 0.
      persistentVolume = {
        enabled = false
      }

      additionalEnv = [
        for k, v in {
          "DOCKER_VERNEMQ_ACCEPT_EULA" = "yes"

          "DOCKER_VERNEMQ_ALLOW_REGISTER_DURING_NETSPLIT"    = "on"
          "DOCKER_VERNEMQ_ALLOW_PUBLISH_DURING_NETSPLIT"     = "on"
          "DOCKER_VERNEMQ_ALLOW_SUBSCRIBE_DURING_NETSPLIT"   = "on"
          "DOCKER_VERNEMQ_ALLOW_UNSUBSCRIBE_DURING_NETSPLIT" = "on"

          "DOCKER_VERNEMQ_ALLOW_ANONYMOUS" = "off"

          # Cleartext WebSocket listener — TLS termination happens at the gateway.
          "DOCKER_VERNEMQ_LISTENER__WS__DEFAULT" = "0.0.0.0:${local.vernemq_ws_port}"

          # vmq_acl ships with a permissive default ACL (`topic #`) that
          # short-circuits the auth_on_publish/subscribe hook chain before our
          # webhook ever runs. Disable it so the webhook is the sole authority.
          "DOCKER_VERNEMQ_PLUGINS__VMQ_ACL" = "off"

          "DOCKER_VERNEMQ_PLUGINS__VMQ_WEBHOOKS" = "on"

          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_REGISTER__HOOK"     = "auth_on_register"
          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_REGISTER__ENDPOINT" = "http://${local.vernemq_auth_name}:${local.vernemq_auth_port}/auth/register"

          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_PUBLISH__HOOK"     = "auth_on_publish"
          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_PUBLISH__ENDPOINT" = "http://${local.vernemq_auth_name}:${local.vernemq_auth_port}/auth/publish"

          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_SUBSCRIBE__HOOK"     = "auth_on_subscribe"
          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_SUBSCRIBE__ENDPOINT" = "http://${local.vernemq_auth_name}:${local.vernemq_auth_port}/auth/subscribe"
        } : { name = k, value = v }
      ]
    })
  ]

  depends_on = [kubernetes_service_v1.vernemq_auth]
}

# Forward `mqtt.mesh.<domain>` traffic from the public LB's per-host HTTPS
# listener to VerneMQ's WS listener. Envoy auto-handles the WebSocket upgrade.
resource "kubectl_manifest" "vernemq_http_route" {
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
        {
          namespace   = var.gateway_namespace
          name        = var.gateway_name
          sectionName = var.mqtt_gateway_section
        }
      ]
      hostnames = [local.vernemq_public_host]
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

  depends_on = [helm_release.vernemq]
}
