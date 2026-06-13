data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = var.vault
}
