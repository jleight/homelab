data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

data "onepassword_item" "usenet" {
  for_each = local.server_secret_names

  vault = local.vault_uuid
  title = "Usenet - ${each.value}"
}
