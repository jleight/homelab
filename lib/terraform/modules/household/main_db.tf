locals {
  # The extension's version is the one in its image tag, so bumping the tag
  # upgrades the extension too.
  vchord_tag = regex(
    "^pg(?P<pg_major>\\d+)-v(?P<version>\\d+\\.\\d+\\.\\d+)$",
    var.database_extensions.vchord.version
  )

  database_extension_images = {
    vchord = {
      image   = "${var.database_extensions.vchord.image}:${var.database_extensions.vchord.version}"
      version = local.vchord_tag.version

      # The scratch image keeps PostgreSQL's own layout rather than CNPG's.
      dynamic_library_path   = ["/usr/lib/postgresql/${local.vchord_tag.pg_major}/lib"]
      extension_control_path = ["/usr/share/postgresql/${local.vchord_tag.pg_major}"]
    }
  }
}

module "database_cluster" {
  source = "../_registry/database_cluster"

  namespace          = module.namespace.name
  data_storage_class = var.database_storage_class

  extension_images         = local.database_extension_images
  shared_preload_libraries = ["vchord"]

  managed_databases = {
    immich = {
      extensions = ["vector", "vchord", "cube", "earthdistance", "pg_trgm", "unaccent", "uuid-ossp"]
    }

    mealie    = {}
    orcatasks = {}
  }
}
