module "database_cluster" {
  source = "../_registry/database_cluster"

  namespace          = module.namespace.name
  data_storage_class = var.database_storage_class

  managed_databases = {
    synapse = {}
  }
}
