locals {
  mealie_domain = "${var.mealie.subdomain}.${var.mealie.gateway_domain}"
  mealie_db     = module.database_cluster.databases["mealie"]
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "mealie_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "mealie-subst"
  }

  data = {
    data_storage_class  = var.mealie.data_storage_class
    gateway_parent_refs = jsonencode(var.mealie.gateway_refs)
    domain              = local.mealie_domain
    db_secret           = local.mealie_db.secret
  }
}

# Values the Deployment reads with envFrom.
resource "kubernetes_config_map_v1" "mealie_env" {
  metadata {
    namespace = module.namespace.name
    name      = "mealie-env"
  }

  data = {
    BASE_URL     = local.mealie_domain
    ALLOW_SIGNUP = tostring(var.mealie.allow_signup)

    POSTGRES_SERVER = module.database_cluster.host
    POSTGRES_PORT   = tostring(module.database_cluster.port)
    POSTGRES_DB     = local.mealie_db.database
    POSTGRES_USER   = local.mealie_db.username
  }
}
