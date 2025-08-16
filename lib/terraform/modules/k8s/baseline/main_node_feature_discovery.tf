resource "helm_release" "node_feature_discovery" {
  count = local.enabled ? 1 : 0

  namespace  = "kube-system"
  name       = "node-feature-discovery"
  repository = var.k8s_baseline.node_feature_discovery.repository
  chart      = var.k8s_baseline.node_feature_discovery.chart
  version    = var.k8s_baseline.node_feature_discovery.version
}
