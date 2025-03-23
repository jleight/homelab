locals {
  prometheus_version = try(var.k8s_cluster.prometheus.version, null)
  prometheus_enabled = local.enabled && local.prometheus_version != null

  prometheus_namespace        = local.prometheus_enabled ? var.k8s_cluster.prometheus.namespace : ""
  prometheus_create_namespace = local.prometheus_enabled && !contains(local.default_k8s_namespaces, local.prometheus_namespace)
}

resource "kubernetes_namespace" "prometheus" {
  count = local.prometheus_create_namespace ? 1 : 0

  metadata {
    name = local.prometheus_namespace

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "helm_release" "prometheus" {
  count = local.prometheus_enabled ? 1 : 0

  namespace  = local.prometheus_namespace
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = local.prometheus_version

  depends_on = [
    kubernetes_namespace.prometheus
  ]
}
