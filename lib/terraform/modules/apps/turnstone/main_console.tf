# Turnstone console: the cluster dashboard and single front door, and the owner
# of the shared database. This is the always-on hub — it owns the CNPG cluster
# that ties the fleet together (servers register into its `services` table),
# discovers nodes from it, and reverse-proxies into each node's UI so users only
# ever hit the console. Also holds the JWT secret used to mint service tokens
# that authenticate to the nodes it proxies.
module "console" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace     = local.namespace
  name          = local.console_name
  app_component = local.console_name

  image         = var.turnstone.image
  image_version = var.turnstone.version

  args = [
    "turnstone-console",
    "--host=0.0.0.0",
    "--port=8090"
  ]

  # Service exposes 8090 directly (not app_deployment's default 80) so the
  # in-cluster console_url advertised below — and the gateway route — both reach
  # the console on the same port the container listens on.
  port         = 8090
  service_port = 8090

  subdomain = var.turnstone.subdomain
  path      = "/"

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  env = {
    TURNSTONE_DB_BACKEND  = "postgresql"
    TURNSTONE_CONSOLE_URL = local.console_url
  }

  secret_env = {
    TURNSTONE_JWT_SECRET = {
      secret_name = local.jwt_secret_name
      key         = "TURNSTONE_JWT_SECRET"
    }
  }

  # The shared cluster database. Servers connect to it (see main_server.tf) to
  # register themselves; the console reads the registry. psycopg3 dialect, URL
  # injected straight from the generated secret.
  postgres_enabled       = true
  postgres_storage_class = var.data_storage_class
  postgres_url_scheme    = "postgresql+psycopg"

  postgres_secret_env_vars = {
    TURNSTONE_DB_URL = "url"
  }
}
