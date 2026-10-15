# Credentials for the registry that ImageBuilds push to. ImageBuilds,
# ImageRepositories and pods all reference the same Secret.
resource "kubernetes_secret_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = local.secret_name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = local.dockerconfigjson
  }
}
