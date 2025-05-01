resource "onepassword_item" "admin_user" {
  count = local.enabled ? 1 : 0

  title    = "Gitea"
  category = "login"
  vault    = local.vault_uuid

  username = local.admin_user_username
  url      = "https://${local.hostname}"

  password_recipe {
    length = 32
  }
}

resource "kubernetes_secret" "admin_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-admin-user"
  }

  data = {
    username = local.admin_user_username
    password = local.admin_user_password
  }
}
