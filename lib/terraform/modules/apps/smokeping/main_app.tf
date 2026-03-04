module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image         = var.smokeping.image
  image_version = var.smokeping.version

  port = 80

  subdomain = var.smokeping.subdomain
  path      = var.smokeping.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  env = {
    TZ = var.smokeping.time_zone
  }

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
  }

  volumes_from_config_maps = {
    config = local.config_cm_name
  }

  volume_mounts = [
    {
      name       = "config"
      mount_path = "/etc/smokeping/config"
      sub_path   = "config"
      read_only  = true
    },
    {
      name       = "data"
      mount_path = "/data"
    }
  ]
}
