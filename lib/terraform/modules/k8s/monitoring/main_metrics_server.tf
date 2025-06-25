locals {
  metrics_server_enabled = local.enabled && var.k8s_monitoring.metrics_server.enabled
}

resource "helm_release" "metrics_server" {
  count = local.metrics_server_enabled ? 1 : 0

  namespace  = try(one(kubernetes_namespace.this[0].metadata).name, null)
  name       = "metrics-server"
  repository = var.k8s_monitoring.metrics_server.repository
  chart      = var.k8s_monitoring.metrics_server.chart
  version    = var.k8s_monitoring.metrics_server.version

  # set_list = [
  #   {
  #     name  = "args"
  #     value = ["--kubelet-preferred-address-types=Hostname,InternalDNS,InternalIP,ExternalDNS,ExternalIP"]
  #   }
  # ]
}
