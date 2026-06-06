locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  # Terraform-managed Zigbee2MQTT config. An init container deep-merges this
  # into the persisted configuration.yaml, so these keys are owned here while
  # Z2M's runtime state (advanced.network_key, pan_id, ext_pan_id, devices) is
  # preserved. Deliberately omits network_key/pan_id so Z2M generates and owns
  # them — never put them here, or a merge would reset the network and force a
  # re-pair of every device. onboarding=false skips the 2.x wizard, which isn't
  # an env-settable key.
  config = {
    onboarding = false

    mqtt = {
      server = "mqtt://${var.mqtt_host}:${var.mqtt_port}"
    }

    # adapter=ember is the EmberZNet driver for the SkyConnect / Connect ZBT-1
    # (Silicon Labs EFR32); port is the device-plugin's bind-mounted node.
    serial = {
      port    = "/dev/zigbee"
      adapter = "ember"
    }

    frontend = {
      enabled = true
      port    = 8080
    }

    # Publish MQTT discovery so Home Assistant auto-adds paired devices (off by
    # default in Z2M). discovery_topic must match HA's MQTT integration
    # discovery prefix, and status_topic is HA's birth/will topic Z2M watches to
    # re-publish discovery when HA restarts — both are HA's defaults.
    homeassistant = {
      enabled         = true
      discovery_topic = "homeassistant"
      status_topic    = "homeassistant/status"
    }

    advanced = {
      log_level = "info"
    }
  }

  config_yaml = yamlencode(local.config)
}
