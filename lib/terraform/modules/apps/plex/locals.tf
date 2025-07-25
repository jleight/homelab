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
      "app.kubernetes.io/version"    = var.plex.version
      "app.kubernetes.io/component"  = "audiobookshelf"
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null
  claim      = local.enabled ? data.onepassword_item.claim[0].password : null

  claim_secret_name = local.enabled ? kubernetes_secret.claim[0].metadata[0].name : null
  media_pvc_name    = local.enabled ? kubernetes_persistent_volume_claim.media[0].metadata[0].name : null
}
