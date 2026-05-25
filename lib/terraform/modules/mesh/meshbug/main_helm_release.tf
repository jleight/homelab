resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.mesh_bug.repository
  chart      = var.mesh_bug.chart
  version    = var.mesh_bug.version

  values = [
    yamlencode({
      # The chart's fullname helper doesn't honor fullnameOverride — it only
      # checks whether nameOverride (or the chart name) is a substring of
      # Release.Name. Release is "mesh-bug" and chart is "meshbug", so the
      # default render is "mesh-bug-meshbug". Setting nameOverride to the
      # release name satisfies the `contains` check and collapses the
      # fullname to just "mesh-bug" — the web Service is then "mesh-bug-web",
      # which is what the HTTPRoute backendRef points at.
      nameOverride = local.name

      postgres = {
        existingSecret    = local.postgres_secret
        existingSecretKey = "dsn"
      }

      ingress = {
        enabled = false
      }

      service = {
        port = local.port
      }

      brokers = local.brokers
    })
  ]
}
