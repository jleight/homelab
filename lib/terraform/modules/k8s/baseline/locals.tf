locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  default_k8s_namespaces = toset([
    "default",
    "kube-node-lease",
    "kube-public",
    "kube-system",
  ])

  terraform_vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null

  nas02 = {
    url      = "//192.168.1.251"
    username = local.enabled ? data.onepassword_item.smb_nas02[0].username : null
    password = local.enabled ? data.onepassword_item.smb_nas02[0].password : null
  }

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
