data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

data "onepassword_item" "admin" {
  count = local.enabled ? 1 : 0

  vault = try(data.onepassword_vault.terraform[0].uuid, null)
  title = "pyMC - Admin"
}

# Per-room-server credentials. One item per room server, titled
# "pyMC Room Server - {name}", with the guest password in the standard
# `password` field and the admin password in an "admin password" custom field.
data "onepassword_item" "room_server" {
  for_each = local.enabled ? { for rs in var.pymc.room_servers : rs.name => rs } : {}

  vault = try(data.onepassword_vault.terraform[0].uuid, null)
  title = "pyMC Room Server - ${each.key}"
}
