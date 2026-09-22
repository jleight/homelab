resource "random_password" "turnstone_jwt" {
  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "turnstone_auth" {
  metadata {
    namespace = module.namespace.name
    name      = "turnstone-auth"
  }

  data = {
    TURNSTONE_JWT_SECRET = random_password.turnstone_jwt.result
    TURNSTONE_DB_URL     = local.turnstone_database_url
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "turnstone_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "turnstone-subst"
  }

  data = {
    gateway_parent_refs = jsonencode(var.turnstone.gateway_refs)
    domain              = local.turnstone_domain
    auth_secret         = kubernetes_secret_v1.turnstone_auth.metadata[0].name
    auth_checksum       = "sha256:${sha256(jsonencode(kubernetes_secret_v1.turnstone_auth.data))}"
  }
}

# Values both workloads read with envFrom.
resource "kubernetes_config_map_v1" "turnstone_env" {
  metadata {
    namespace = module.namespace.name
    name      = "turnstone-env"
  }

  data = {
    TURNSTONE_DB_BACKEND  = "postgresql"
    TURNSTONE_CONSOLE_URL = local.turnstone_console_url
    TURNSTONE_SEARXNG_URL = local.searxng_url
  }
}
