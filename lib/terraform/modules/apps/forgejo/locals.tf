locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace.this[0].metadata[0].name : null

  hostname = "${var.forgejo.subdomain}.${var.gateway_domain}"

  vault_uuid          = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  admin_user_username = var.username
  admin_user_password = local.enabled ? onepassword_item.admin_user[0].password : null
  admin_user_secret   = local.enabled ? kubernetes_secret.admin_user[0].metadata[0].name : null

  postgres_secret   = local.enabled ? kubernetes_secret.postgres[0].metadata[0].name : null
  postgres_username = local.enabled ? random_pet.postgres_user[0].id : null
  postgres_password = local.enabled ? random_password.postgres_user[0].result : null
}
