# OpenWebRX's admin account is created on first boot from the OPENWEBRX_ADMIN_*
# env vars and then persisted in the config volume. Generate random credentials,
# stash them in 1Password (alongside the service URL) for the human to retrieve,
# and hand them to the pod via a Kubernetes Secret.
resource "random_pet" "admin_user" {
  count = local.enabled ? 1 : 0
}

resource "random_password" "admin_user" {
  count = local.enabled ? 1 : 0

  length = 32
}

resource "onepassword_item" "admin_user" {
  count = local.enabled ? 1 : 0

  title    = "OpenWebRX+"
  category = "login"
  vault    = local.vault_uuid

  username = local.admin_user_username
  password = local.admin_user_password
  url      = "https://${local.hostname}"
}

resource "kubernetes_secret_v1" "admin_user" {
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
