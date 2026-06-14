module "bridge" {
  source  = "../../_registry/app_deployment"
  context = local.context

  name = local.bridge_name

  namespace = var.namespace

  image         = var.romm.bridge.image
  image_version = var.romm.bridge.version
  image_digest  = var.romm.bridge.digest

  port         = local.bridge_port
  service_port = local.bridge_service_port

  # Routing is handled by the custom HTTPRoutes in main_bridge_routes.tf, which
  # need a URLRewrite filter the built-in ingress doesn't support.
  ingress_enabled = false

  env = merge(
    {
      ROMM_BASE_URL          = local.romm_base_url
      INDEX_REFRESH_INTERVAL = var.romm.bridge.index_refresh_interval
      STORE_PATH             = "/data/pairings.json"
      LOG_LEVEL              = var.romm.bridge.log_level
    },
    var.romm.bridge.platform_map == null ? {} : {
      PLATFORM_MAP = var.romm.bridge.platform_map
    }
  )

  env_from_secrets = local.enabled ? [local.bridge_secret_name] : []

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/data"
    }
  ]
}
