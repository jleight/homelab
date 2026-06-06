module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image         = var.esphome.image
  image_version = var.esphome.version

  port = 6052

  subdomain = var.esphome.subdomain
  path      = var.esphome.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  persistent_volume_claims = {
    config = {
      storage_class = var.data_storage_class
    }
  }

  # Build cache (platformio/compiled artifacts) — regenerable, so an emptyDir
  # is fine. It rebuilds after a pod restart; no need to persist it.
  volumes_empty_dir = ["cache"]

  volume_mounts = [
    {
      name       = "config"
      mount_path = "/config"
    },
    {
      name       = "cache"
      mount_path = "/cache"
    }
  ]
}
