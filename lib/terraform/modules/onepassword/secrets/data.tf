data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

data "onepassword_item" "tailscale_k8s_operator" {
  count = local.enabled ? 1 : 0

  vault = try(data.onepassword_vault.terraform[0].uuid, null)
  title = var.tailscale_k8s_operator_item
}

data "onepassword_item" "cloudflare_api_token" {
  count = local.enabled ? 1 : 0

  vault = try(data.onepassword_vault.terraform[0].uuid, null)
  title = var.cloudflare_api_token_item
}

data "onepassword_item" "smb_nas02" {
  count = local.enabled ? 1 : 0

  vault = try(data.onepassword_vault.terraform[0].uuid, null)
  title = var.smb_nas02_item
}

data "onepassword_item" "lets_encrypt_staging" {
  count = local.enabled ? 1 : 0

  vault = try(data.onepassword_vault.terraform[0].uuid, null)
  title = var.lets_encrypt_staging_item
}

data "onepassword_item" "lets_encrypt_production" {
  count = local.enabled ? 1 : 0

  vault = try(data.onepassword_vault.terraform[0].uuid, null)
  title = var.lets_encrypt_production_item
}
