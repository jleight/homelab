locals {
  namespace = local.enabled ? kubernetes_namespace.this[0].metadata[0].name : null
  name      = local.component
}

resource "kubernetes_namespace" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = "cnpg-system"
  }
}

resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.postgres.repository
  chart      = var.postgres.chart
  version    = var.postgres.version

  set = [
    for k, v in {
      "monitoring.grafanaDashboard.create" = true
    } : { name = k, value = v }
  ]
}
