# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "homepage_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "homepage-subst"
  }

  data = {
    gateway_parent_refs = jsonencode(var.homepage.gateway_refs)
    domain              = local.homepage_domain
    gateway_domain      = var.homepage.gateway_domain
  }
}
