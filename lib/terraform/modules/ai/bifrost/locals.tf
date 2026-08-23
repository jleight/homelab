locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name     = local.component
  hostname = "${var.bifrost.subdomain}.${var.gateway_domain}"

  vault_uuid          = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  admin_user_username = local.enabled ? random_pet.admin_user[0].id : null
  admin_user_password = local.enabled ? random_password.admin_user[0].result : null

  secret_name = local.enabled ? kubernetes_secret_v1.this[0].metadata[0].name : null
}
