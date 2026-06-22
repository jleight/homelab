# Allow the Woodpecker deployer ServiceAccount (which lives in another namespace)
# to roll new image tags onto this Deployment, and nothing else.
resource "kubernetes_role_v1" "deployer" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-deployer"

    labels = local.labels
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch", "patch"]
  }
}

resource "kubernetes_role_binding_v1" "deployer" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-deployer"

    labels = local.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.deployer[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.deployer_service_account_name
    namespace = var.deployer_service_account_namespace
  }
}
