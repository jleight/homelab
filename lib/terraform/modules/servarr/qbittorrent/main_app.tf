module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace
  name      = local.name

  image         = var.qbittorrent.image
  image_version = var.qbittorrent.version

  port = local.flood_port

  extra_service_ports = [
    {
      name        = "qbittorrent"
      port        = local.qbittorrent_port
      target_port = local.qbittorrent_port
    }
  ]

  subdomain = var.flood.subdomain
  path      = "${local.path}/"

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  ingress_extra_rules = [
    {
      matches = [
        {
          path = {
            type  = "Exact"
            value = local.path
          }
        }
      ]
      filters = [
        {
          type = "RequestRedirect"
          requestRedirect = {
            path = {
              type            = "ReplaceFullPath"
              replaceFullPath = "${local.path}/"
            }
            statusCode = 302
          }
        }
      ]
    }
  ]

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
    media = {
      storage_class = var.media_storage_class
      storage_size  = "10Ti"
    }
  }

  volumes_from_config_maps = {
    config = local.config_cm_name
  }

  volume_mounts = [
    {
      name       = "config"
      mount_path = "/config/qBittorrent/qBittorrent.conf"
      sub_path   = "qBittorrent.conf"
      read_only  = true
    },
    {
      name       = "data"
      mount_path = "/config/qBittorrent"
    },
    {
      name       = "media"
      mount_path = "/media"
    }
  ]

  extra_containers = [
    {
      name                 = "flood"
      image                = "${var.flood.image}:${var.flood.version}"
      port                 = local.flood_port
      env_from_config_maps = [local.flood_env_cm_name]
      env_from_secrets     = [local.flood_secret_name]
    }
  ]
}
