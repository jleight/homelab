# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "weewx_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "weewx-subst"
  }

  data = {
    image           = "${module.namespace.registry_image_prefix}/weewx"
    registry_secret = module.namespace.registry_secret_name

    data_storage_class = var.data_storage_class

    gateway_parent_refs      = jsonencode(var.gateway_refs)
    gateway_http_parent_refs = jsonencode([for r in var.gateway_refs : merge(r, { sectionName = "http" })])
    domain                   = "${var.weewx.subdomain}.${var.gateway_domain}"
  }
}
