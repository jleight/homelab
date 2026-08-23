# Bifrost encrypts stored provider credentials with this key. Losing or rotating
# it makes anything already written to the config store unreadable.
resource "random_password" "encryption_key" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = local.name
  }

  data = {
    BIFROST_ENCRYPTION_KEY = random_password.encryption_key[0].result
    BIFROST_ADMIN_USERNAME = local.admin_user_username
    BIFROST_ADMIN_PASSWORD = local.admin_user_password

    # The stack-level db module owns the role and its password; this just hands
    # it to the container as an env var config.json can reference.
    PG_PASSWORD = var.db_password
  }
}
