locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  admin_secret   = local.enabled ? kubernetes_secret_v1.admin_user[0].metadata[0].name : null
  admin_username = local.enabled ? random_pet.admin_user[0].id : null
  admin_password = local.enabled ? random_password.admin_user[0].result : null

  bifrost_secret   = local.enabled ? kubernetes_secret_v1.bifrost_user[0].metadata[0].name : null
  bifrost_username = local.enabled ? "bifrost" : null
  bifrost_password = local.enabled ? random_password.bifrost_user[0].result : null

  open_webui_secret   = local.enabled ? kubernetes_secret_v1.open_webui_user[0].metadata[0].name : null
  open_webui_username = local.enabled ? "openwebui" : null
  open_webui_password = local.enabled ? random_password.open_webui_user[0].result : null
}
