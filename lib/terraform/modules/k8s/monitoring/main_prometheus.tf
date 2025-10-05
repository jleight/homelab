locals {
  prometheus_enabled = local.enabled && var.k8s_monitoring.prometheus.enabled

  prometheus_crds = local.prometheus_enabled ? {
    for crd in data.helm_template.prometheus[0].crds : yamldecode(crd).metadata.name => crd
  } : {}
}

data "helm_template" "prometheus" {
  count = local.prometheus_enabled ? 1 : 0

  namespace  = try(one(kubernetes_namespace.this[0].metadata).name, null)
  name       = "prometheus"
  repository = var.k8s_monitoring.prometheus.repository
  chart      = var.k8s_monitoring.prometheus.chart
  version    = var.k8s_monitoring.prometheus.version

  kube_version = var.k8s_version
}


resource "kubectl_manifest" "prometheus_crds" {
  for_each = local.prometheus_crds

  server_side_apply = true
  force_conflicts   = true

  yaml_body = each.value
}

resource "helm_release" "prometheus" {
  count = local.prometheus_enabled ? 1 : 0

  namespace  = try(one(kubernetes_namespace.this[0].metadata).name, null)
  name       = "prometheus"
  repository = var.k8s_monitoring.prometheus.repository
  chart      = var.k8s_monitoring.prometheus.chart
  version    = var.k8s_monitoring.prometheus.version

  skip_crds = true

  set = [
    {
      name  = "grafana.sidecar.dashboards.searchNamespace"
      value = "ALL"
    }
  ]
}
