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
      "app.kubernetes.io/version"    = var.homebridge.version
      "app.kubernetes.io/component"  = "homebridge"
      "app.kubernetes.io/part-of"    = local.name
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  port     = 8581
  hostname = "${var.homebridge.subdomain}.${var.gateway_domain}"
  path     = var.homebridge.path

  service_account_name = local.enabled ? kubernetes_service_account.this[0].metadata[0].name : null
  service_name         = local.enabled ? kubernetes_service.this[0].metadata[0].name : null
  data_pvc_name        = local.enabled ? kubernetes_persistent_volume_claim.data[0].metadata[0].name : null
}
