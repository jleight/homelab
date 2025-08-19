locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
}
