# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "zwave_js_ui_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "zwave-js-ui-subst"
  }

  data = {
    data_storage_class = var.data_storage_class
  }
}

# Z-Wave network security keys (128-bit each), held in Terraform state and
# written into settings.json via the managed Secret. These MUST stay stable:
# changing them would orphan every securely-included device and force a
# re-include.
resource "random_id" "zwave_key" {
  for_each = toset(["S0_Legacy", "S2_Unauthenticated", "S2_Authenticated", "S2_AccessControl"])

  byte_length = 16
}

# Z-Wave Long Range uses its own S2 keys (no S0, no Unauthenticated).
resource "random_id" "zwave_key_lr" {
  for_each = toset(["S2_Authenticated", "S2_AccessControl"])

  byte_length = 16
}
