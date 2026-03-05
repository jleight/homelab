module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace     = local.namespace
  app_component = "media-server"

  image         = var.plex.image
  image_version = var.plex.version

  replicas = var.plex.replicas

  port         = 32400
  service_port = 32400

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section

  env = {
    VERSION = "latest"
  }

  secret_env = {
    PLEX_CLAIM = {
      secret_name = local.claim_secret_name
      key         = "claim"
    }
  }

  resource_limits = {
    "gpu.intel.com/i915" = "1"
  }

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
      storage_size  = "100Gi"
    }
    media = {
      storage_class = var.media_storage_class
      storage_size  = "10Ti"
    }
  }

  volumes_empty_dir = [
    "transcode"
  ]

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/config"
    },
    {
      name       = "transcode"
      mount_path = "/transcode"
    },
    {
      name       = "media"
      mount_path = "/media"
    }
  ]
}
