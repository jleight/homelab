locals {
  sonarr_db = module.database_cluster.databases["sonarr"]

  # Rendered whole and copied over /config/config.xml by an init container on
  # every start, so this is the only place the API key, URL base and database
  # credentials are set.
  sonarr_config = templatefile(
    "${path.module}/etc/sonarr.xml.tftpl",
    {
      port    = 8989
      path    = trimprefix(var.sonarr.path, "/")
      auth    = var.sonarr.auth
      api_key = replace(random_uuid.sonarr_api_key.result, "-", "")

      db_host     = local.db_host
      db_port     = local.db_port
      db_username = local.sonarr_db.username
      db_password = module.database_cluster.passwords["sonarr"]
    }
  )
}

resource "random_uuid" "sonarr_api_key" {}

resource "kubernetes_secret_v1" "sonarr_config" {
  metadata {
    namespace = module.namespace.name
    name      = "sonarr-config"
  }

  data = {
    "config.xml" = local.sonarr_config
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "sonarr_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "sonarr-subst"
  }

  data = {
    data_storage_class  = var.data_storage_class
    media_storage_class = var.media_storage_class
    gateway_parent_refs = jsonencode(var.gateway_refs)
    domain              = local.media_domain
    path                = var.sonarr.path
    config_secret       = kubernetes_secret_v1.sonarr_config.metadata[0].name
    config_checksum     = "sha256:${nonsensitive(sha256(local.sonarr_config))}"
  }
}
