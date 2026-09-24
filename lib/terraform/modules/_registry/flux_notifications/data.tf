data "onepassword_vault" "this" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

data "onepassword_item" "matrix" {
  count = local.enabled ? 1 : 0

  vault = data.onepassword_vault.this[0].uuid
  title = "Matrix - flux"
}
