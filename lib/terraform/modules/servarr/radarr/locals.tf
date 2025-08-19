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
      "app.kubernetes.io/version"    = var.radarr.version
      "app.kubernetes.io/component"  = "radarr"
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  port     = 7878
  hostname = "${var.radarr.subdomain}.${var.gateway_domain}"
  path     = var.radarr.path

  service_account_name = local.enabled ? kubernetes_service_account.this[0].metadata[0].name : null
  service_name         = local.enabled ? kubernetes_service.this[0].metadata[0].name : null
  config_secret_name   = local.enabled ? kubernetes_secret.config[0].metadata[0].name : null
  data_pvc_name        = local.enabled ? kubernetes_persistent_volume_claim.data[0].metadata[0].name : null
  media_pvc_name       = local.enabled ? kubernetes_persistent_volume_claim.media[0].metadata[0].name : null
}
