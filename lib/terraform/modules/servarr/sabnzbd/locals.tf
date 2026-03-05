locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  port = 8080

  vault_uuid          = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  server_secret_names = local.enabled ? toset([for k, v in var.sabnzbd.servers : v.secret_name]) : toset([])
  config_secret_name  = local.enabled ? kubernetes_secret_v1.config[0].metadata[0].name : null
}
