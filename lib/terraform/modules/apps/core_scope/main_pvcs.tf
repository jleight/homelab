# SQLite lives here. Must be a local / single-replica class; distributed
# block storage (eg. Longhorn with >1 replica) corrupts SQLite.
resource "kubernetes_persistent_volume_claim_v1" "data" {
  count = local.enabled ? 1 : 0

  # WaitForFirstConsumer on the local SC means the PVC binds when the pod
  # schedules, so we have to skip the default wait-bound behavior.
  wait_until_bound = false

  metadata {
    namespace = local.namespace
    name      = "${local.name}-data"

    labels = local.labels
  }

  spec {
    storage_class_name = var.data_storage_class
    access_modes       = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.data_storage_size
      }
    }
  }
}

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
