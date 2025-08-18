locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  admin_secret   = local.enabled ? kubernetes_secret.admin_user[0].metadata[0].name : null
  admin_username = local.enabled ? random_pet.admin_user[0].id : null
  admin_password = local.enabled ? random_password.admin_user[0].result : null

  sonarr_secret   = local.enabled ? kubernetes_secret.sonarr_user[0].metadata[0].name : null
  sonarr_username = local.enabled ? "sonarr" : null
  sonarr_password = local.enabled ? random_password.sonarr_user[0].result : null
}
