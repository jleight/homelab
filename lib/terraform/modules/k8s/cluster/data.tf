data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = "Terraform"
}

data "onepassword_item" "cloudflare_api_token" {
  count = local.enabled ? 1 : 0

  vault = local.terraform_vault_uuid
  title = "Cloudflare API Token"
}

data "cloudflare_zones" "cluster" {
  count = local.enabled ? 1 : 0

  name = var.k8s_cluster.domain
}

module "ipam" {
  source = "../../_registry/ipam"

  environment = var.environment
}

module "slaac_pd" {
  for_each = local.enabled ? var.k8s_cluster.nodes : {}
  source   = "../../_registry/slaac"

  prefix      = module.ipam.lan.v6_prefix
  mac_address = each.value.mac_address
}
