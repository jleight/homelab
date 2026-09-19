resource "kubernetes_namespace_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = "flux-system"

    labels = {
      "app.kubernetes.io/instance"         = "flux-system"
      "app.kubernetes.io/part-of"          = "flux"
      "pod-security.kubernetes.io/enforce" = "restricted"
    }
  }
}
