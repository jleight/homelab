# Shared JWT signing secret. Both the server and console must reference the same
# value, so it's generated once here rather than via app_deployment's per-app
# secret generation.
resource "random_password" "jwt" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "auth" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "auth"
  }

  data = {
    TURNSTONE_JWT_SECRET = local.jwt_secret
  }
}
