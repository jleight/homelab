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

      service = {
        type = "ClusterIP"
        mqtt = {
          enabled = true
        }
      }

      persistentVolume = {
        enabled = false
      }

      # The chart's 90s initialDelaySeconds is sized for a multi-node cluster
      # negotiating netsplit/queue handoff on boot. At replicaCount = 1 with no
      # persistent volume this broker is serving in ~11s, so the default left it
      # marked unready — and every client disconnected — for ~84s of doing
      # nothing.
      #
      # initialDelaySeconds is a hard floor: kubelet will not probe before it
      # elapses no matter how fast the app is. This chart renders no
      # startupProbe, so the floor is the only lever. Readiness polls from 5s
      # every 5s; liveness keeps a 30s floor so a slow start (the entrypoint
      # retries the API server until cluster DNS answers) can't get the
      # container killed before it finishes.
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

          "DOCKER_VERNEMQ_ALLOW_ANONYMOUS"    = "on"
          "DOCKER_VERNEMQ_MAX_CLIENT_ID_SIZE" = "256"

          "DOCKER_VERNEMQ_ALLOW_REGISTER_DURING_NETSPLIT"    = "on"
          "DOCKER_VERNEMQ_ALLOW_PUBLISH_DURING_NETSPLIT"     = "on"
          "DOCKER_VERNEMQ_ALLOW_SUBSCRIBE_DURING_NETSPLIT"   = "on"
          "DOCKER_VERNEMQ_ALLOW_UNSUBSCRIBE_DURING_NETSPLIT" = "on"
        } : { name = k, value = v }
      ]
    })
  ]
}
