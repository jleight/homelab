resource "kubernetes_namespace" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = "monitoring"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}
