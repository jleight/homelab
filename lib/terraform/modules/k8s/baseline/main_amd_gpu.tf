resource "helm_release" "amd_gpu" {
  count = local.enabled ? 1 : 0

  namespace  = "kube-system"
  name       = "amd-gpu"
  repository = var.k8s_baseline.amd_gpu.repository
  chart      = var.k8s_baseline.amd_gpu.chart
  version    = var.k8s_baseline.amd_gpu.version

  set = [
    {
      name  = "node_selector_enabled"
      value = "true"
    }
  ]
}
