module "database_cluster" {
  source = "../_registry/database_cluster"

  namespace          = module.namespace.name
  data_storage_class = var.database_storage_class

  managed_databases = {
    chaptarr = {
      databases = ["chaptarr-main", "chaptarr-log", "chaptarr-cache"]
    }

    radarr = {
      databases = ["radarr-main", "radarr-log"]
    }

    romm = {}

    sonarr = {
      databases = ["sonarr-main", "sonarr-log"]
    }
  }
}
