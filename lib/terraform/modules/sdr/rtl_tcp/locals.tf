locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name = local.component
  port = 1234
}
