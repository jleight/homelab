data "kubernetes_service" "radarr" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = var.radarr_service_name
  }
}

data "onepassword_vault" "terraform" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

data "onepassword_item" "nzbfinder" {
  count = local.enabled ? 1 : 0

  vault = local.vault_uuid
  title = "Usenet - NZBFinder"
}

data "onepassword_item" "plex" {
  count = local.enabled ? 1 : 0

  vault = local.vault_uuid
  title = "Plex - OAuth Token"
}
