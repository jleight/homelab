resource "kubernetes_namespace_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = local.stack

    labels = {
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"

      # Not `restricted`: the Prosody entrypoint starts as root to usermod the
      # prosody account to match the data volume's ownership, then drops to it
      # with runuser before exec'ing the server.
      "pod-security.kubernetes.io/enforce" = "baseline"
    }
  }
}
