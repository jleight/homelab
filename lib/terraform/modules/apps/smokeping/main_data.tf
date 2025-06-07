resource "kubernetes_persistent_volume_claim" "data" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-data"

    labels = local.labels
  }

  spec {
    storage_class_name = var.data_storage_class

    resources {
      requests = {
        storage = "100Mi"
      }
    }

    access_modes = [
      "ReadWriteMany"
    ]
  }
}
