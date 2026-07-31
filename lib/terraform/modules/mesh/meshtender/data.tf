module "ipam" {
  source = "../../_registry/ipam"

  environment = local.environment
}

data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

# Resend API key for MeshTender's transactional mail, in the item's standard
# `credential` field.
data "onepassword_item" "resend" {
  count = local.enabled ? 1 : 0

  vault = try(data.onepassword_vault.terraform[0].uuid, null)
  title = "MeshTender - Resend"
}
