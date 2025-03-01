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

data "external" "node_ip" {
  for_each = local.enabled ? var.k8s_cluster.nodes : {}

  program = ["bash", "${path.module}/lib/get-ip.sh"]

  query = {
    password    = var.sudo_password
    interface   = var.network_interface
    mac_address = each.value.mac_address
  }
}
