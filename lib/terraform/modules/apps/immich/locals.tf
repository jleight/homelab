locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null

  port     = 2283
  hostname = "${var.immich.subdomain}.${var.gateway_domain}"
  path     = var.immich.path

  postgres_secret   = local.enabled ? kubernetes_secret_v1.postgres[0].metadata[0].name : null
  postgres_username = local.enabled ? random_pet.postgres_user[0].id : null
  postgres_password = local.enabled ? random_password.postgres_user[0].result : null

  service_name   = local.enabled ? "${local.name}-server" : null
  media_pvc_name = local.enabled ? kubernetes_persistent_volume_claim_v1.media[0].metadata[0].name : null
}
