resource "kubectl_manifest" "instance" {
  count = local.enabled ? 1 : 0

  server_side_apply = true

  yaml_body = yamlencode({
    apiVersion = "fluxcd.controlplane.io/v1"
    kind       = "FluxInstance"

    metadata = {
      name      = "flux"
      namespace = local.namespace
    }

    spec = {
      distribution = {
        registry = var.k8s_flux.distribution.registry
        version  = var.k8s_flux.distribution.version
      }

      components = [
        "source-controller",
        "kustomize-controller",
        "helm-controller",
        "notification-controller",
        "image-reflector-controller",
        "image-automation-controller"
      ]

      cluster = {
        type          = "kubernetes"
        multitenant   = false
        networkPolicy = true
        size          = "small"
      }

      sync = {
        kind     = "GitRepository"
        url      = var.k8s_flux.sync.url
        ref      = var.k8s_flux.sync.ref
        path     = var.k8s_flux.sync.path
        interval = var.k8s_flux.sync.interval
      }
    }
  })

  depends_on = [helm_release.operator]
}
