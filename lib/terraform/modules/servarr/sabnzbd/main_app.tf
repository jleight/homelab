module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.sabnzbd.image
  image_version = var.sabnzbd.version

  port = local.port

  subdomain = var.sabnzbd.subdomain
  path      = var.sabnzbd.path

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
      name    = "sabnzbd-config"
      command = ["/bin/sh", "-c", "cp /secret/sabnzbd.ini /config/sabnzbd.ini"]
      volume_mounts = [
        {
          name       = "secret"
          mount_path = "/secret/sabnzbd.ini"
          sub_path   = "sabnzbd.ini"
          read_only  = true
        },
        {
          name       = "data"
          mount_path = "/config"
        }
      ]
    }
  ]

  volumes_from_secrets = {
    secret = local.config_secret_name
  }

  volumes_empty_dir = [
    "temp"
  ]

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/config"
    },
    {
      name       = "temp"
      mount_path = "/config/logs"
      sub_path   = "logs"
    },
    {
      name       = "temp"
      mount_path = "/downloads/incomplete"
      sub_path   = "incomplete"
    },
    {
      name       = "media"
      mount_path = "/downloads/unsorted"
      sub_path   = "unsorted"
    }
  ]
}
