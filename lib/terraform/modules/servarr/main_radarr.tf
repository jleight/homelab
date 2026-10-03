locals {
  radarr_db = module.database_cluster.databases["radarr"]

  # Rendered whole and copied over /config/config.xml by an init container on
  # every start, so this is the only place the API key, URL base and database
  # credentials are set.
  radarr_config = templatefile(
    "${path.module}/etc/radarr.xml.tftpl",
    {
      port    = 7878
      path    = trimprefix(var.radarr.path, "/")
      auth    = var.radarr.auth
      api_key = replace(random_uuid.radarr_api_key.result, "-", "")

      db_host     = local.db_host
      db_port     = local.db_port
      db_username = local.radarr_db.username
      db_password = module.database_cluster.passwords["radarr"]
    }
  )
}

resource "random_uuid" "radarr_api_key" {}

resource "kubernetes_secret_v1" "radarr_config" {
  metadata {
    namespace = module.namespace.name
    name      = "radarr-config"
  }

  data = {
    "config.xml" = local.radarr_config
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "radarr_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "radarr-subst"
  }

  data = {
    data_storage_class  = var.data_storage_class
    media_storage_class = var.media_storage_class
    gateway_parent_refs = jsonencode(var.gateway_refs)
    domain              = local.media_domain
    path                = var.radarr.path
    config_secret       = kubernetes_secret_v1.radarr_config.metadata[0].name
    config_checksum     = "sha256:${nonsensitive(sha256(local.radarr_config))}"
  }
}
