data "onepassword_item" "igdb" {
  vault = data.onepassword_vault.this.uuid
  title = "IGDB - API Client"
}

data "onepassword_item" "steamgriddb" {
  vault = data.onepassword_vault.this.uuid
  title = "SteamGridDB - API Key"
}

data "onepassword_item" "retroachievements" {
  vault = data.onepassword_vault.this.uuid
  title = "RetroAchievements - API Key"
}

locals {
  romm_domain = "${var.romm.subdomain}.${var.gateway_domain}"
  romm_db     = module.database_cluster.databases["romm"]
}

# Signs RomM's sessions. Regenerating it only logs everyone out.
resource "random_password" "romm_auth_secret_key" {
  length  = 32
  special = false
}

resource "kubernetes_secret_v1" "romm" {
  metadata {
    namespace = module.namespace.name
    name      = "romm"
  }

  data = {
    ROMM_AUTH_SECRET_KEY = random_password.romm_auth_secret_key.result
    DB_PASSWD            = module.database_cluster.passwords["romm"]

    IGDB_CLIENT_SECRET        = data.onepassword_item.igdb.credential
    STEAMGRIDDB_API_KEY       = data.onepassword_item.steamgriddb.credential
    RETROACHIEVEMENTS_API_KEY = data.onepassword_item.retroachievements.credential
  }
}

# Values the Deployment reads with envFrom.
resource "kubernetes_config_map_v1" "romm_env" {
  metadata {
    namespace = module.namespace.name
    name      = "romm-env"
  }

  data = {
    DB_HOST        = local.db_host
    DB_PORT        = tostring(local.db_port)
    DB_NAME        = local.romm_db.database
    DB_USER        = local.romm_db.username
    IGDB_CLIENT_ID = data.onepassword_item.igdb.username
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "romm_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "romm-subst"
  }

  data = {
    media_storage_class = var.media_storage_class
    gateway_parent_refs = jsonencode(var.gateway_refs)
    domain              = local.romm_domain
    secret_checksum     = "sha256:${nonsensitive(sha256(jsonencode(kubernetes_secret_v1.romm.data)))}"
  }
}
