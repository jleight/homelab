# Allow the GHCR deploy webhook's ServiceAccount (which lives in another
# namespace) to roll new images onto this Deployment, and nothing else. The
# image and env fields are ignore_changes'd, so the webhook owns what is running.
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

resource "kubernetes_role_binding_v1" "ghcr_deploy" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-ghcr-deploy"

    labels = local.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.deployer[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.ghcr_deploy_service_account_name
    namespace = var.ghcr_deploy_service_account_namespace
  }
}
