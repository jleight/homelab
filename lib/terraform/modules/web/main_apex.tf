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

# Mounted by the apex nginx at /srv/www/.well-known/matrix. Mounted as a
# directory (not subPath) so changes reach the pod without a restart.
resource "kubernetes_config_map_v1" "apex_well_known_matrix" {
  metadata {
    namespace = module.namespace.name
    name      = "apex-well-known-matrix"
  }

  data = {
    client = jsonencode({
      "m.homeserver" = {
        base_url = var.apex.matrix_client_base_url
      }
    })
  }
}
