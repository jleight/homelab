locals {
  immich_domain = "${var.immich.subdomain}.${var.immich.gateway_domain}"
  immich_db     = module.database_cluster.databases["immich"]
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "immich_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "immich-subst"
  }

  data = {
    media_storage_class = var.immich.media_storage_class
    gateway_parent_refs = jsonencode(var.immich.gateway_refs)
    domain              = local.immich_domain

    db_host   = module.database_cluster.host
    db_port   = tostring(module.database_cluster.port)
    db_name   = local.immich_db.database
    db_user   = local.immich_db.username
    db_secret = local.immich_db.secret

    # Immich only checks VectorChord's version when it starts, so the pods
    # carry it as an annotation to restart after an upgrade.
    vchord_version = local.database_extension_images.vchord.version
  }
}
