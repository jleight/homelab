resource "helm_release" "image_build_controller" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = "image-build-controller"
  repository = var.k8s_flux.image_build_controller.repository
  chart      = var.k8s_flux.image_build_controller.chart
  version    = var.k8s_flux.image_build_controller.version

  set = [
    for k, v in {
      # The FluxInstance's NetworkPolicies only admit flux-system to
      # source-controller, so build pods in other namespaces could not
      # fetch their GitRepository artifacts without this.
      "sourceControllerNetworkPolicy.enabled" = true
    } : { name = k, value = v }
  ]

  depends_on = [kubectl_manifest.instance]
}
