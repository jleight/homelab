locals {
  node_exporter_enabled = local.enabled && var.k8s_monitoring.node_exporter.enabled

  # Pinned rather than release-derived so the VictoriaMetrics scrape job can match on it.
  node_exporter_service_name = "node-exporter"
}

resource "helm_release" "node_exporter" {
  count = local.node_exporter_enabled ? 1 : 0

  namespace  = local.monitoring_namespace
  name       = "node-exporter"
  repository = var.k8s_monitoring.node_exporter.repository
  chart      = var.k8s_monitoring.node_exporter.chart
  version    = var.k8s_monitoring.node_exporter.version

  set = [
    {
      name  = "fullnameOverride"
      value = local.node_exporter_service_name
    }
  ]
}
