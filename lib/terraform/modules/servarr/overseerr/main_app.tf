module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.overseerr.image
  image_version = var.overseerr.version

  port = 5055

  subdomain = var.overseerr.subdomain
  path      = var.overseerr.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/app/config"
    }
  ]
}
