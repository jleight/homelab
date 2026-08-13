terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//servarr/chaptarr"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "db" {
  config_path = "../db"
}

inputs = {
  component = "chaptarr"

  namespace = dependency.namespace.outputs.name

  data_storage_class  = dependency.k8s_storage.outputs.app_data_storage_class_name
  media_storage_class = dependency.k8s_storage.outputs.media_storage_class_name

  gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain

  db_host     = dependency.db.outputs.host
  db_port     = dependency.db.outputs.port
  db_username = dependency.db.outputs.chaptarr_username
  db_password = dependency.db.outputs.chaptarr_password

  db_main_name  = dependency.db.outputs.chaptarr_main_db
  db_log_name   = dependency.db.outputs.chaptarr_log_db
  db_cache_name = dependency.db.outputs.chaptarr_cache_db
}
