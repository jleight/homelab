locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  port = 8080

  vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null

  igdb_client_id            = local.enabled ? data.onepassword_item.igdb[0].username : null
  igdb_client_secret        = local.enabled ? data.onepassword_item.igdb[0].credential : null
  steamgriddb_api_key       = local.enabled ? data.onepassword_item.steamgriddb[0].credential : null
  retroachievements_api_key = local.enabled ? data.onepassword_item.retroachievements[0].credential : null

  auth_secret_name = local.enabled ? kubernetes_secret_v1.auth[0].metadata[0].name : null
  config_map_name  = local.enabled ? kubernetes_config_map_v1.config[0].metadata[0].name : null
}

locals {
  bridge_name         = "${local.component}-retroarch-bridge"
  bridge_port         = 8080
  bridge_service_port = 80

  romm_base_url = local.enabled ? "http://${module.app.service_name}.${var.namespace}.svc.cluster.local" : null

  romm_api_token     = local.enabled ? data.onepassword_item.romm_api_token[0].credential : null
  bridge_secret_name = local.enabled ? kubernetes_secret_v1.bridge[0].metadata[0].name : null
}
