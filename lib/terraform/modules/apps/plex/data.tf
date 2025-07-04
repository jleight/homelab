data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

data "onepassword_item" "claim" {
  count = local.enabled ? 1 : 0

  vault = local.vault_uuid
  title = "Plex - Claim - ${local.environment}"
}
