resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.mesh_bug.repository
  chart      = var.mesh_bug.chart
  version    = var.mesh_bug.version

  values = [
    yamlencode({
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
