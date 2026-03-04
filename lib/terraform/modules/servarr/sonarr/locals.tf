locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  port = 8989

  config_secret_name = local.enabled ? kubernetes_secret_v1.config[0].metadata[0].name : null
}
