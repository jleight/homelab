# ServiceAccount that CD steps run as (via backend_options.kubernetes.serviceAccountName).
# It lives in the namespace where step pods are created (shared with Forgejo); each
# deployed app grants it patch rights in its own namespace with a RoleBinding (see
# README), so a leaked pipeline cannot touch namespaces it was never bound to.
resource "kubernetes_service_account_v1" "deployer" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-deployer"
  }
}
