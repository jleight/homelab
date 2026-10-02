# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "zigbee2mqtt_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "zigbee2mqtt-subst"
  }

  data = {
    data_storage_class = var.data_storage_class
  }
}
