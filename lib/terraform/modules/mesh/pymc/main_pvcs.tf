# Single NAS-backed (SMB) share holding two subfolders: config/ (the persisted
# config.yaml — so UI edits and jwt_secret survive restarts) and backup/ (the
# Litestream SQLite replica). SMB is RWX, so it attaches on any node and nothing
# pins the pod — it can reschedule onto the other modem node on failure.
#
# The SQLite *working copy* is NOT here — it lives on a local emptyDir (see the
# deployment), since SQLite must not run directly on a network filesystem.
resource "kubernetes_persistent_volume_claim_v1" "share" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-share"

    labels = local.labels
  }

  spec {
    storage_class_name = var.share_storage_class
    access_modes       = ["ReadWriteMany"]

    resources {
      requests = {
        storage = var.share_storage_size
      }
    }
  }
}
