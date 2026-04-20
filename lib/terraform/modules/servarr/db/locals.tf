locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  admin_secret   = local.enabled ? kubernetes_secret_v1.admin_user[0].metadata[0].name : null
  admin_username = local.enabled ? random_pet.admin_user[0].id : null
  admin_password = local.enabled ? random_password.admin_user[0].result : null

  sonarr_secret   = local.enabled ? kubernetes_secret_v1.sonarr_user[0].metadata[0].name : null
  sonarr_username = local.enabled ? "sonarr" : null
  sonarr_password = local.enabled ? random_password.sonarr_user[0].result : null

  radarr_secret   = local.enabled ? kubernetes_secret_v1.radarr_user[0].metadata[0].name : null
  radarr_username = local.enabled ? "radarr" : null
  radarr_password = local.enabled ? random_password.radarr_user[0].result : null

  romm_secret   = local.enabled ? kubernetes_secret_v1.romm_user[0].metadata[0].name : null
  romm_username = local.enabled ? "romm" : null
  romm_password = local.enabled ? random_password.romm_user[0].result : null
}
