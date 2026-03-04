module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace
  replicas  = 2

  image         = var.trakr.image
  image_version = var.trakr.version

  port = 3000

  subdomain = var.trakr.subdomain
  path      = var.trakr.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  postgres_enabled       = true
  postgres_storage_class = var.data_storage_class

  postgres_secret_env_vars = {
    DATABASE_URL = "url"
  }
}
