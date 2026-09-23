resource "kubernetes_persistent_volume_claim_v1" "this" {
  for_each = local.enabled ? var.persistent_volume_claims : {}

  metadata {
    namespace = var.namespace
    name      = "${local.name}-${each.key}"

    labels = local.labels
  }

  spec {
    storage_class_name = each.value.storage_class

    resources {
      requests = {
        storage = each.value.storage_size
      }
    }

    access_modes = each.value.access_modes
  }

  # A WaitForFirstConsumer class never binds until the Deployment's pod exists,
  # and the Deployment depends on this PVC, so waiting would deadlock the apply.
  wait_until_bound = each.value.wait_until_bound
}
