# imagePullSecret so the kubelet can pull MeshTender's private image from the
# Forgejo registry. Built from the CI bot's read credentials.
resource "kubernetes_secret_v1" "registry" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-registry"

    labels = local.labels
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.registry_host) = {
          username = var.registry_username
          password = var.registry_password
          auth     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }
}
