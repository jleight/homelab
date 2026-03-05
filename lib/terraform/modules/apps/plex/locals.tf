locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null

  vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  claim      = local.enabled ? data.onepassword_item.claim[0].password : null

  claim_secret_name = local.enabled ? kubernetes_secret_v1.claim[0].metadata[0].name : null
}
