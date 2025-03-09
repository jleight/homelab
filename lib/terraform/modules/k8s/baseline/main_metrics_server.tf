locals {
  metrics_server_version = try(var.k8s_cluster.metrics_server.version, null)
  metrics_server_enabled = local.enabled && local.metrics_server_version != null

  metrics_server_namespace        = local.metrics_server_enabled ? var.k8s_cluster.metrics_server.namespace : ""
  metrics_server_create_namespace = local.metrics_server_enabled && !contains(local.default_k8s_namespaces, local.metrics_server_namespace)
}

resource "kubernetes_namespace" "metrics_server" {
  count = local.metrics_server_create_namespace ? 1 : 0

  metadata {
    name = local.metrics_server_namespace
  }
}

resource "helm_release" "metrics_server" {
  count = local.metrics_server_enabled ? 1 : 0

  namespace  = local.metrics_server_namespace
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = local.metrics_server_version

  dynamic "set" {
    for_each = local.metrics_server_enabled && !local.kubelet_cert_approver_enabled ? ["0"] : []

    content {
      name  = "args[0]"
      value = "--kubelet-insecure-tls"
    }
  }
}
