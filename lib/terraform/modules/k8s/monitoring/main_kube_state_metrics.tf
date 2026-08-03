locals {
  kube_state_metrics_enabled = local.enabled && var.k8s_monitoring.kube_state_metrics.enabled

  # Pinned rather than release-derived so the VictoriaMetrics scrape job can match on it.
  kube_state_metrics_service_name = "kube-state-metrics"
}

resource "helm_release" "kube_state_metrics" {
  count = local.kube_state_metrics_enabled ? 1 : 0

  namespace  = local.monitoring_namespace
  name       = "kube-state-metrics"
  repository = var.k8s_monitoring.kube_state_metrics.repository
  chart      = var.k8s_monitoring.kube_state_metrics.chart
  version    = var.k8s_monitoring.kube_state_metrics.version

  set = [
    {
      name  = "fullnameOverride"
      value = local.kube_state_metrics_service_name
    }
  ]
}
