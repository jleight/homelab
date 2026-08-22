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

      # The chart's 90s initialDelaySeconds is sized for a multi-node cluster
      # negotiating netsplit/queue handoff on boot. At replicaCount = 1 with no
      # persistent volume, VerneMQ is serving in ~7s (config, then the SWC meta,
      # DKM and msgstore LevelDB stores), so the default left the broker marked
      # unready — and every client disconnected — for ~85s of doing nothing.
      #
      # initialDelaySeconds is a hard floor: kubelet will not probe before it
      # elapses no matter how fast the app is. This chart renders no
      # startupProbe, so the floor is the only lever. Readiness polls from 5s
      # every 5s; liveness keeps a 30s floor (4x the observed boot) so a slow
      # start can't get the container killed before it finishes.
      statefulset = {
        readinessProbe = {
          initialDelaySeconds = 5
          periodSeconds       = 5
        }

        livenessProbe = {
          initialDelaySeconds = 30
        }
      }

      additionalEnv = [
        for k, v in {
          "DOCKER_VERNEMQ_ACCEPT_EULA" = "yes"

          "DOCKER_VERNEMQ_ALLOW_REGISTER_DURING_NETSPLIT"    = "on"
          "DOCKER_VERNEMQ_ALLOW_PUBLISH_DURING_NETSPLIT"     = "on"
          "DOCKER_VERNEMQ_ALLOW_SUBSCRIBE_DURING_NETSPLIT"   = "on"
          "DOCKER_VERNEMQ_ALLOW_UNSUBSCRIBE_DURING_NETSPLIT" = "on"

          "DOCKER_VERNEMQ_ALLOW_ANONYMOUS" = "off"

          "DOCKER_VERNEMQ_MAX_CLIENT_ID_SIZE" = "256"

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
