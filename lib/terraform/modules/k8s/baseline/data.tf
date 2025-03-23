data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = "Terraform"
}

data "onepassword_item" "smb_nas02" {
  count = local.enabled ? 1 : 0

  vault = local.terraform_vault_uuid
  title = "SMB - nas02"
}

data "onepassword_item" "lets_encrypt_staging" {
  count = local.enabled ? 1 : 0

  vault = local.terraform_vault_uuid
  title = "Let's Encrypt Staging"
}

data "onepassword_item" "lets_encrypt_production" {
  count = local.enabled ? 1 : 0

  vault = local.terraform_vault_uuid
  title = "Let's Encrypt Production"
}

data "onepassword_item" "cloudflare_api_token" {
  count = local.enabled ? 1 : 0

  vault = local.terraform_vault_uuid
  title = "Cloudflare API Token"
}

module "ipam" {
  source = "../../_registry/ipam"

  environment = var.environment
}
