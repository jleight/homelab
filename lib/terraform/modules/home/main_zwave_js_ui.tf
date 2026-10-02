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

locals {
  # Terraform-managed zwave-js-ui settings. An init container deep-merges this
  # into the persisted settings.json, so these keys win while zwave-js-ui's
  # runtime state (node data, the mqtt/gateway/ui sections) is preserved.
  #   - port:          the device-plugin's bind-mounted Z-Wave node
  #   - serverEnabled: the Z-Wave JS websocket server HA connects to (port 3000)
  #   - securityKeys:  the network keys above
  zwave_js_ui_config = jsonencode({
    zwave = {
      port          = "/dev/zwave"
      serverEnabled = true
      serverPort    = 3000
      logLevel      = "info"

      # mDNS advertisement of the Z-Wave JS server (so HA can discover it).
      serverServiceDiscoveryDisabled = false

      # RFRegion enum; 1 = USA. zwave-js-ui stores this numerically.
      rf = {
        region = 1
      }

      securityKeys          = { for k, r in random_id.zwave_key : k => upper(r.hex) }
      securityKeysLongRange = { for k, r in random_id.zwave_key_lr : k => upper(r.hex) }
    }

    mqtt = {
      disabled = true
    }

    gateway = {
      hassDiscovery = false
    }
  })
}

# A Secret (not a ConfigMap) because the settings include the network keys.
resource "kubernetes_secret_v1" "zwave_js_ui_config" {
  metadata {
    namespace = module.namespace.name
    name      = "zwave-js-ui-config"
  }

  data = {
    "settings.json" = local.zwave_js_ui_config
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "zwave_js_ui_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "zwave-js-ui-subst"
  }

  data = {
    data_storage_class  = var.data_storage_class
    gateway_parent_refs = jsonencode(var.gateway_refs)
    domain              = "${var.zwave_js_ui.subdomain}.${var.gateway_domain}"
    config_checksum     = "sha256:${sha256(local.zwave_js_ui_config)}"
  }
}
