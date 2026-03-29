module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.romm.image
  image_version = var.romm.version

  port = local.port

  subdomain = var.romm.subdomain
  path      = var.romm.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  env = {
    ROMM_DB_DRIVER = "postgresql"
    DB_HOST        = var.db_host
    DB_PORT        = tostring(var.db_port)
    DB_NAME        = "romm"
    DB_USER        = var.db_username

    ROMM_PORT = local.port

    IGDB_CLIENT_ID       = local.igdb_client_id
    HASHEOUS_API_ENABLED = "true"
  }

  env_from_secrets = local.enabled ? [local.auth_secret_name] : []

  volumes_from_config_maps = local.enabled ? {
    config = local.config_map_name
  } : {}

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
    media = {
      storage_class = var.media_storage_class
      storage_size  = "10Ti"
    }
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/romm/resources"
      sub_path   = "resources"
    },
    {
      name       = "data"
      mount_path = "/redis-data"
      sub_path   = "redis-data"
    },
    {
      name       = "config"
      mount_path = "/romm/config/config.yml"
      sub_path   = "config.yml"
      read_only  = true
    },
    {
      name       = "media"
      mount_path = "/romm/library/roms"
      sub_path   = "roms/roms"
    },
    {
      name       = "media"
      mount_path = "/romm/library/bios"
      sub_path   = "roms/bios"
    },
    {
      name       = "media"
      mount_path = "/romm/assets"
      sub_path   = "roms/assets"
    }
  ]
}
