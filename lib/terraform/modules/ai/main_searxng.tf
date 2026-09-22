resource "random_password" "searxng_secret_key" {
  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "searxng" {
  metadata {
    namespace = module.namespace.name
    name      = "searxng"
  }

  data = {
    SEARXNG_SECRET = random_password.searxng_secret_key.result
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "searxng_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "searxng-subst"
  }

  data = {
    gateway_parent_refs = jsonencode(var.searxng.gateway_refs)
    domain              = local.searxng_domain
  }
}

# Values the Deployment reads with envFrom.
resource "kubernetes_config_map_v1" "searxng_env" {
  metadata {
    namespace = module.namespace.name
    name      = "searxng-env"
  }

  data = {
    SEARXNG_BASE_URL = "https://${local.searxng_domain}"
  }
}
