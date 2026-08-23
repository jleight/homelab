# Signs and encrypts session cookies and JWTs. Rotating these logs everyone out
# but is otherwise harmless -- unlike Bifrost's encryption key, nothing at rest
# is encrypted with them.
resource "random_password" "jwt_secret" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "random_password" "sig_key" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "random_password" "sig_salt" {
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
    DATABASE_URL               = local.database_url
    PGVECTOR_CONNECTION_STRING = local.database_url

    GENERIC_OPEN_AI_API_KEY = local.bifrost_api_key

    AUTH_TOKEN = local.password
    JWT_SECRET = random_password.jwt_secret[0].result
    SIG_KEY    = random_password.sig_key[0].result
    SIG_SALT   = random_password.sig_salt[0].result
  }
}
