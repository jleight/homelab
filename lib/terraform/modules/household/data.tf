data "onepassword_vault" "this" {
  name = var.vault
}

data "onepassword_item" "device_screen_id" {
  vault = data.onepassword_vault.this.uuid
  title = var.isponsorblocktv.device_screen_id_item
}
