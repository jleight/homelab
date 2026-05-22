data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

data "onepassword_item" "ha_mqtt" {
  count = local.enabled ? 1 : 0

  vault = local.vault_uuid
  title = "Home Assistant - MQTT"
}
