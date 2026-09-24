# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "apex_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "apex-subst"
  }

  data = {
    apex_gateway_parent_refs = jsonencode(var.apex.apex_gateway_refs)
    www_gateway_parent_refs  = jsonencode(var.apex.www_gateway_refs)
    domain                   = var.apex.gateway_domain
    redirect_hostname        = var.apex.redirect_hostname
  }
}
