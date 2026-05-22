resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.vernemq_name
  repository = var.mqtt.repository
  chart      = var.mqtt.chart
  version    = var.mqtt.version

  values = [
    yamlencode({
      fullnameOverride = local.vernemq_name

      replicaCount = 1

      # mqtt: plain TCP on 1883 for in-cluster subscribers/publishers.
      # ws: MQTT-over-WebSocket on 8080 — the public LB terminates TLS on 443
      # for `mqtt.mesh.<domain>` and forwards cleartext WS in-cluster.
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

          "DOCKER_VERNEMQ_LISTENER__WS__DEFAULT" = "0.0.0.0:${local.vernemq_ws_port}"

          "DOCKER_VERNEMQ_PLUGINS__VMQ_ACL" = "off"

          "DOCKER_VERNEMQ_PLUGINS__VMQ_WEBHOOKS" = "on"

          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_REGISTER__HOOK"     = "auth_on_register"
          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_REGISTER__ENDPOINT" = "http://${local.auth_name}:${local.auth_port}/auth/register"

          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_PUBLISH__HOOK"     = "auth_on_publish"
          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_PUBLISH__ENDPOINT" = "http://${local.auth_name}:${local.auth_port}/auth/publish"

          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_SUBSCRIBE__HOOK"     = "auth_on_subscribe"
          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_SUBSCRIBE__ENDPOINT" = "http://${local.auth_name}:${local.auth_port}/auth/subscribe"
        } : { name = k, value = v }
      ]
    })
  ]

  depends_on = [kubernetes_service_v1.auth]
}
