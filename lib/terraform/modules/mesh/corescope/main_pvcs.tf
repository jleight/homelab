# Litestream replicates WAL segments here. Backed by SMB to the NAS.
resource "kubernetes_persistent_volume_claim_v1" "backup" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-backup"

    labels = local.labels
  }

  spec {
    storage_class_name = var.backup_storage_class
    access_modes       = ["ReadWriteMany"]

    resources {
      requests = {
        storage = var.backup_storage_size
      }
    }
  }
}
