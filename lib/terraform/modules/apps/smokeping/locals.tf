locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null

  config_cm_name = local.enabled ? kubernetes_config_map_v1.config[0].metadata[0].name : null
}
