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

  anything_llm_secret   = local.enabled ? kubernetes_secret_v1.anything_llm_user[0].metadata[0].name : null
  anything_llm_username = local.enabled ? "anythingllm" : null
  anything_llm_password = local.enabled ? random_password.anything_llm_user[0].result : null
}
