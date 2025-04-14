locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace.this[0].metadata[0].name : null

  match_labels = {
    "app.kubernetes.io/name"     = local.name
    "app.kubernetes.io/instance" = local.name
  }

  labels = merge(
    local.match_labels,
    {
      "app.kubernetes.io/version"    = var.smokeping.version
      "app.kubernetes.io/component"  = "smokeping"
      "app.kubernetes.io/part-of"    = local.name
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  service_account_name = local.enabled ? kubernetes_service_account.this[0].metadata[0].name : null
  service_name         = local.enabled ? kubernetes_service.this[0].metadata[0].name : null
  config_cm_name       = local.enabled ? kubernetes_config_map.config[0].metadata[0].name : null
  data_pvc_name        = local.enabled ? kubernetes_persistent_volume_claim.data[0].metadata[0].name : null

  ingress_public_enabled  = local.enabled && var.smokeping.ingress == "public"
  ingress_private_enabled = local.enabled && var.smokeping.ingress == "private"
}
