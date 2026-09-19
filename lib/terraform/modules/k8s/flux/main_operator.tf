resource "helm_release" "operator" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = "flux-operator"
  repository = var.k8s_flux.operator.repository
  chart      = var.k8s_flux.operator.chart
  version    = var.k8s_flux.operator.version
}
