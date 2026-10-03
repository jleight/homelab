locals {
  chaptarr_db = module.database_cluster.databases["chaptarr"]

  # Rendered whole and copied over /config/config.xml by an init container on
  # every start, so this is the only place the API key, URL base and database
  # credentials are set.
  chaptarr_config = templatefile(
    "${path.module}/etc/chaptarr.xml.tftpl",
    {
      port    = 8789
      path    = trimprefix(var.chaptarr.path, "/")
      auth    = var.chaptarr.auth
      api_key = replace(random_uuid.chaptarr_api_key.result, "-", "")

      db_host     = local.db_host
      db_port     = local.db_port
      db_username = local.chaptarr_db.username
      db_password = module.database_cluster.passwords["chaptarr"]

      # Chaptarr does not default these the way Sonarr and Radarr do.
      db_main_name  = "chaptarr-main"
      db_log_name   = "chaptarr-log"
      db_cache_name = "chaptarr-cache"
    }
  )
}

resource "random_uuid" "chaptarr_api_key" {}

resource "kubernetes_secret_v1" "chaptarr_config" {
  metadata {
    namespace = module.namespace.name
    name      = "chaptarr-config"
  }

  data = {
    "config.xml" = local.chaptarr_config
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "chaptarr_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "chaptarr-subst"
  }

  data = {
    data_storage_class  = var.data_storage_class
    media_storage_class = var.media_storage_class
    gateway_parent_refs = jsonencode(var.gateway_refs)
    domain              = local.media_domain
    path                = var.chaptarr.path
    config_secret       = kubernetes_secret_v1.chaptarr_config.metadata[0].name
    config_checksum     = "sha256:${nonsensitive(sha256(local.chaptarr_config))}"
  }
}
