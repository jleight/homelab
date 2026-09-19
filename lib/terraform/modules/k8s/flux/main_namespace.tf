# Terraform creates this namespace only because something has to exist before
# the operator's Helm release and the FluxInstance can be placed in it. The
# operator then adopts it: flux-system is part of the Flux distribution, so
# every reconcile re-applies it with its own labels (managed-by, the running
# Flux version, the owning FluxInstance) and, importantly, the annotations that
# mark it prune-protected for both the operator and kustomize-controller.
#
# Without ignore_changes, every apply strips that metadata and the next
# reconcile puts it back — a permanent diff, and a window where the namespace
# is not marked prune-protected. The operator owns this metadata; we only own
# the namespace's existence.
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

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations
    ]
  }
}
