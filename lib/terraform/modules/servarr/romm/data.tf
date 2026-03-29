data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

data "onepassword_item" "igdb" {
  count = local.enabled ? 1 : 0

  vault = local.vault_uuid
  title = "IGDB - API Client"
}

data "onepassword_item" "steamgriddb" {
  count = local.enabled ? 1 : 0

  vault = local.vault_uuid
  title = "SteamGridDB - API Key"
}

data "onepassword_item" "retroachievements" {
  count = local.enabled ? 1 : 0

  vault = local.vault_uuid
  title = "RetroAchievements - API Key"
}
