# Values Flux substitutes into the manifests before applying them. Shared by
# reverse-proxy-public and reverse-proxy-private; each route picks its own refs.
resource "kubernetes_config_map_v1" "reverse_proxy_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "reverse-proxy-subst"
  }

  data = {
    public_gateway_parent_refs  = jsonencode(var.reverse_proxy.public_gateway_refs)
    private_gateway_parent_refs = jsonencode(var.reverse_proxy.private_gateway_refs)
    gateway_domain              = var.reverse_proxy.gateway_domain
  }
}
