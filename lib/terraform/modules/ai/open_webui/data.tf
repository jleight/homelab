data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

data "onepassword_item" "bifrost" {
  count = local.enabled ? 1 : 0

  vault = try(data.onepassword_vault.terraform[0].uuid, null)
  title = "Bifrost - Open WebUI"
}
