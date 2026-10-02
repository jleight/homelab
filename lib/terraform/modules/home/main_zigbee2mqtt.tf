locals {
  # Terraform-managed Zigbee2MQTT config. An init container deep-merges this
  # into the persisted configuration.yaml, so these keys are owned here while
  # Z2M's runtime state (advanced.network_key, pan_id, ext_pan_id, devices) is
  # preserved. Deliberately omits network_key/pan_id so Z2M generates and owns
  # them — never put them here, or a merge would reset the network and force a
  # re-pair of every device. onboarding=false skips the 2.x wizard, which isn't
  # an env-settable key.
  zigbee2mqtt_config = yamlencode({
    onboarding = false

    mqtt = {
      server = "mqtt://${local.mqtt_host}:${local.mqtt_port}"
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
  })
}

resource "kubernetes_config_map_v1" "zigbee2mqtt_config" {
  metadata {
    namespace = module.namespace.name
    name      = "zigbee2mqtt-config"
  }

  data = {
    "configuration.yaml" = local.zigbee2mqtt_config
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "zigbee2mqtt_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "zigbee2mqtt-subst"
  }

  data = {
    data_storage_class  = var.data_storage_class
    gateway_parent_refs = jsonencode(var.gateway_refs)
    domain              = "${var.zigbee2mqtt.subdomain}.${var.gateway_domain}"
    config_checksum     = "sha256:${sha256(local.zigbee2mqtt_config)}"
  }
}
