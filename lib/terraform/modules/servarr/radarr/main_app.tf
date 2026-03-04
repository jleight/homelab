module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.radarr.image
  image_version = var.radarr.version

  port = local.port

  subdomain = var.radarr.subdomain
  path      = var.radarr.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
    media = {
      storage_class = var.media_storage_class
      storage_size  = "10Ti"
    }
  }

  init_containers = [
    {
      name    = "radarr-config"
      command = ["/bin/sh", "-c", "cp /config/config.xml /data/config.xml"]
      volume_mounts = [
        {
          name       = "config"
          mount_path = "/config/config.xml"
          sub_path   = "config.xml"
          read_only  = true
        },
        {
          name       = "data"
          mount_path = "/data"
        }
      ]
    }
  ]

  volumes_from_secrets = {
    config = local.config_secret_name
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/config"
    },
    {
      name       = "media"
      mount_path = "/movies"
      sub_path   = "movies"
    },
    {
      name       = "media"
      mount_path = "/downloads"
      sub_path   = "unsorted"
    }
  ]
}
