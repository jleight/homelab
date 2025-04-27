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
        storage = "50Mi"
      }
    }

    access_modes = [
      "ReadWriteMany"
    ]
  }
}

resource "kubernetes_persistent_volume_claim" "media" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-media"

    labels = local.labels
  }

  spec {
    storage_class_name = var.media_storage_class

    resources {
      requests = {
        storage = "10Ti"
      }
    }

    access_modes = [
      "ReadWriteMany"
    ]
  }
}
