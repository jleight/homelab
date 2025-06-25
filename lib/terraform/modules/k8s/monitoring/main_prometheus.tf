locals {
  prometheus_enabled = local.enabled && var.k8s_monitoring.prometheus.enabled
}

resource "helm_release" "prometheus" {
  count = local.prometheus_enabled ? 1 : 0

  namespace  = try(one(kubernetes_namespace.this[0].metadata).name, null)
  name       = "prometheus"
  repository = var.k8s_monitoring.prometheus.repository
  chart      = var.k8s_monitoring.prometheus.chart
  version    = var.k8s_monitoring.prometheus.version

  set = [
    {
      name  = "sidecar.dashboards.searchNamespace"
      value = "ALL"
    }
  ]
}
