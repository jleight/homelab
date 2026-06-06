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
