locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  match_labels = {
    "app.kubernetes.io/name"     = local.name
    "app.kubernetes.io/instance" = local.name
  }

  labels = merge(
    local.match_labels,
    {
      "app.kubernetes.io/version"    = var.qbittorrent.version
      "app.kubernetes.io/component"  = "qbittorrent"
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  hostname = "${var.flood.subdomain}.${var.gateway_domain}"
  port     = var.flood.port
  path     = var.flood.path

  service_account_name = local.enabled ? kubernetes_service_account.this[0].metadata[0].name : null
  service_name         = local.enabled ? kubernetes_service.this[0].metadata[0].name : null
  config_cm_name       = local.enabled ? kubernetes_config_map.config[0].metadata[0].name : null
  flood_env_cm_name    = local.enabled ? kubernetes_config_map.flood_env[0].metadata[0].name : null
  flood_secret_name    = local.enabled ? kubernetes_secret.flood[0].metadata[0].name : null
  data_pvc_name        = local.enabled ? kubernetes_persistent_volume_claim.data[0].metadata[0].name : null
  media_pvc_name       = local.enabled ? kubernetes_persistent_volume_claim.media[0].metadata[0].name : null
}
