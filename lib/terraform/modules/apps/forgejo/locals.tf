locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null

  hostname = "${var.forgejo.subdomain}.${var.gateway_domain}"

  vault_uuid          = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  admin_user_username = var.username
  admin_user_password = local.enabled ? onepassword_item.admin_user[0].password : null
  admin_user_secret   = local.enabled ? kubernetes_secret_v1.admin_user[0].metadata[0].name : null

  postgres_secret   = local.enabled ? kubernetes_secret_v1.postgres[0].metadata[0].name : null
  postgres_username = local.enabled ? random_pet.postgres_user[0].id : null
  postgres_password = local.enabled ? random_password.postgres_user[0].result : null

  # A dedicated role + database in the Forgejo Postgres cluster for Woodpecker CI,
  # which shares this instance. Kept here because only the cluster owner can manage
  # roles declaratively; ready to move with the database if these ever split out.
  woodpecker_database          = "woodpecker"
  woodpecker_postgres_secret   = local.enabled ? kubernetes_secret_v1.woodpecker_postgres[0].metadata[0].name : null
  woodpecker_postgres_username = local.enabled ? random_pet.woodpecker_postgres_user[0].id : null
  woodpecker_postgres_password = local.enabled ? random_password.woodpecker_postgres_user[0].result : null
}
