resource "random_pet" "admin_user" {
  count = local.enabled ? 1 : 0
}

resource "random_password" "admin_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret" "admin_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-admin-user"
  }

  data = {
    username = local.admin_username
    password = local.admin_password
  }
}
