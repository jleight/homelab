resource "kubernetes_namespace_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = local.name

    labels = merge(
      {
        "app.kubernetes.io/part-of"          = local.part_of
        "app.kubernetes.io/managed-by"       = "Terraform"
        "pod-security.kubernetes.io/enforce" = var.pod_security_enforcement
      },
      var.instance == null ? {} : {
        "app.kubernetes.io/instance" = var.instance
      }
    )
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations
    ]
  }
}
