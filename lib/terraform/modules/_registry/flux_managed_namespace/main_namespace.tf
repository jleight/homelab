resource "kubernetes_namespace_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = local.stack

    labels = {
      "app.kubernetes.io/part-of"          = local.stack
      "app.kubernetes.io/managed-by"       = "Terraform"
      "pod-security.kubernetes.io/enforce" = var.pod_security_enforcement
    }
  }
}
