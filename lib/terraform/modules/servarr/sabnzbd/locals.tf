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
      "app.kubernetes.io/version"    = var.sabnzbd.version
      "app.kubernetes.io/component"  = "sabnzbd"
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  vault_uuid          = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  server_secret_names = local.enabled ? toset([for k, v in var.sabnzbd.servers : v.secret_name]) : toset([])

  hostname = "${var.sabnzbd.subdomain}.${var.gateway_domain}"
  path     = var.sabnzbd.path

  service_account_name = local.enabled ? kubernetes_service_account.this[0].metadata[0].name : null
  service_name         = local.enabled ? kubernetes_service.this[0].metadata[0].name : null
  config_secret_name   = local.enabled ? kubernetes_secret.config[0].metadata[0].name : null
  config_pvc_name      = local.enabled ? kubernetes_persistent_volume_claim.config[0].metadata[0].name : null
  media_pvc_name       = local.enabled ? kubernetes_persistent_volume_claim.media[0].metadata[0].name : null
}
