module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.sonarr.image
  image_version = var.sonarr.version

  port = local.port

  subdomain = var.sonarr.subdomain
  path      = var.sonarr.path

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
      name    = "sonarr-config"
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
      mount_path = "/tv"
      sub_path   = "shows"
    },
    {
      name       = "media"
      mount_path = "/downloads"
      sub_path   = "unsorted"
    }
  ]
}
