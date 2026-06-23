module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image         = var.esphome.image
  image_version = var.esphome.version

  port         = 6052
  host_network = true

  subdomain = var.esphome.subdomain
  path      = var.esphome.path

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

  persistent_volume_claims = {
    config = {
      storage_class = var.data_storage_class
    }
  }

  # Build cache (platformio/compiled artifacts) — regenerable, so an emptyDir
  # is fine. It rebuilds after a pod restart; no need to persist it.
  #
  # ESPHome also writes compiled firmware / build artifacts into /config/.esphome,
  # which would otherwise fill the small config PVC. Those are regenerable too, so
  # back that path with its own emptyDir (nested under the /config PVC mount) to
  # keep them off the PVC.
  volumes_empty_dir = ["cache", "build"]

  volume_mounts = [
    {
      name       = "config"
      mount_path = "/config"
    },
    {
      name       = "cache"
      mount_path = "/cache"
    },
    {
      name       = "build"
      mount_path = "/config/.esphome"
    }
  ]
}
