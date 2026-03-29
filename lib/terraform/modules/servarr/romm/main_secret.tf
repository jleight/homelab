resource "random_password" "auth_secret_key" {
  count = local.enabled ? 1 : 0

  length  = 32
  special = false
}

resource "kubernetes_secret_v1" "auth" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.component}-auth"
  }

  data = {
    ROMM_AUTH_SECRET_KEY = local.enabled ? random_password.auth_secret_key[0].result : ""
    DB_PASSWD            = var.db_password

    IGDB_CLIENT_SECRET        = local.igdb_client_secret
    STEAMGRIDDB_API_KEY       = local.steamgriddb_api_key
    RETROACHIEVEMENTS_API_KEY = local.retroachievements_api_key
  }
}
