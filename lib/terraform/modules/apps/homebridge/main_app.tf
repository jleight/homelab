module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image         = var.homebridge.image
  image_version = var.homebridge.version

  port         = 8581
  host_network = var.homebridge.host_network

  subdomain = var.homebridge.subdomain
  path      = var.homebridge.path

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
      mount_path = "/homebridge"
    }
  ]
}
