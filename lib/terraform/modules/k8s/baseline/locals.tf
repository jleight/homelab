locals {
  cluster_kubeconfig_file = replace(var.cluster_kubeconfig_file, "////", "/")

  terraform_vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null

  lets_encrypt = {
    staging = {
      email  = local.enabled ? data.onepassword_item.lets_encrypt_staging[0].username : null
      server = local.enabled ? data.onepassword_item.lets_encrypt_staging[0].url : null
    }
    production = {
      email  = local.enabled ? data.onepassword_item.lets_encrypt_production[0].username : null
      server = local.enabled ? data.onepassword_item.lets_encrypt_production[0].url : null
    }
  }

  cloudflare_api_token = local.enabled ? data.onepassword_item.cloudflare_api_token[0].credential : null
}
