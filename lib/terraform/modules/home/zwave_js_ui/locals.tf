locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  # Terraform-managed zwave-js-ui settings. An init container deep-merges this
  # into the persisted settings.json, so these keys win while zwave-js-ui's
  # runtime state (node data, the mqtt/gateway/ui sections) is preserved.
  #   - port:          the device-plugin's bind-mounted Z-Wave node
  #   - serverEnabled: the Z-Wave JS websocket server HA connects to (port 3000)
  #   - securityKeys:  the generated network keys (see main_keys.tf)
  config = {
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
  }

  config_json = jsonencode(local.config)
}
