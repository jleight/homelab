# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "matter_server_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "matter-server-subst"
  }

  data = {
    data_storage_class = var.data_storage_class
  }
}
