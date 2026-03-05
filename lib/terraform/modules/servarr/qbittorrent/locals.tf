locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  flood_port       = 3000
  qbittorrent_port = 8080
  path             = var.flood.path

  config_cm_name    = local.enabled ? kubernetes_config_map_v1.config[0].metadata[0].name : null
  flood_env_cm_name = local.enabled ? kubernetes_config_map_v1.flood_env[0].metadata[0].name : null
  flood_secret_name = local.enabled ? kubernetes_secret_v1.flood[0].metadata[0].name : null
}
