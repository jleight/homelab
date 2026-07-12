locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  admin_secret   = local.enabled ? kubernetes_secret_v1.admin_user[0].metadata[0].name : null
  admin_username = local.enabled ? random_pet.admin_user[0].id : null
  admin_password = local.enabled ? random_password.admin_user[0].result : null

  pgtt_secret   = local.enabled ? kubernetes_secret_v1.pgtt_user[0].metadata[0].name : null
  pgtt_username = local.enabled ? "pgtt" : null
  pgtt_password = local.enabled ? random_password.pgtt_user[0].result : null
}
