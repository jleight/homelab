module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image         = var.mealie.image
  image_version = var.mealie.version

  port = 9000

  subdomain = var.mealie.subdomain
  path      = var.mealie.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  env = {
    BASE_URL     = "${var.mealie.subdomain}.${var.gateway_domain}"
    ALLOW_SIGNUP = tostring(var.mealie.allow_signup)
    DB_ENGINE    = "postgres"
  }

  postgres_enabled       = true
  postgres_storage_class = var.data_storage_class

  postgres_env_vars = {
    POSTGRES_SERVER = "host"
    POSTGRES_PORT   = "port"
    POSTGRES_DB     = "database"
    POSTGRES_USER   = "username"
  }

  postgres_secret_env_vars = {
    POSTGRES_PASSWORD = "password"
  }

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/app/data"
    }
  ]
}
