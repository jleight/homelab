locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace.this[0].metadata[0].name : null

  hostname = "${var.gitea.subdomain}.${var.gateway_domain}"

  vault_uuid          = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  admin_user_username = var.username
  admin_user_password = local.enabled ? onepassword_item.admin_user[0].password : null
  admin_user_secret   = local.enabled ? kubernetes_secret.admin_user[0].metadata[0].name : null

  data_pvc_name = local.enabled ? kubernetes_persistent_volume_claim.data[0].metadata[0].name : null
}
