data "onepassword_item" "romm_api_token" {
  vault = data.onepassword_vault.this.uuid
  title = "RomM - API Token"
}

resource "kubernetes_secret_v1" "romm_retroarch_bridge" {
  metadata {
    namespace = module.namespace.name
    name      = "romm-retroarch-bridge"
  }

  data = {
    ROMM_API_TOKEN = data.onepassword_item.romm_api_token.credential
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "romm_retroarch_bridge_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "romm-retroarch-bridge-subst"
  }

  data = {
    data_storage_class = var.data_storage_class
    domain             = local.romm_domain
    path               = var.romm.bridge_path

    # The bridge serves plain HTTP as well, for clients that can't do HTTPS.
    gateway_parent_refs      = jsonencode(var.gateway_refs)
    gateway_http_parent_refs = jsonencode([for r in var.gateway_refs : merge(r, { sectionName = "http" })])

    secret_checksum = "sha256:${nonsensitive(sha256(jsonencode(kubernetes_secret_v1.romm_retroarch_bridge.data)))}"
  }
}
