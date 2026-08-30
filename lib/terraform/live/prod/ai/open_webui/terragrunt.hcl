terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//ai/open_webui"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "db" {
  config_path = "../db"
}

dependency "bifrost" {
  config_path = "../bifrost"
}

dependency "searxng" {
  config_path = "../searxng"
}

# The Dragonfly CR needs the operator's CRD registered before it can apply.
dependencies {
  paths = ["../../apps/dragonflydb"]
}

inputs = {
  component = "open-webui"

  namespace = dependency.namespace.outputs.name

  gateway_refs   = dependency.k8s_ingress.outputs.public_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain

  data_storage_class    = dependency.k8s_storage.outputs.app_data_storage_class_name
  uploads_storage_class = dependency.k8s_storage.outputs.backups_storage_class_name

  db_host     = dependency.db.outputs.host
  db_port     = dependency.db.outputs.port
  db_username = dependency.db.outputs.open_webui_username
  db_password = dependency.db.outputs.open_webui_password

  bifrost_base_url  = dependency.bifrost.outputs.internal_openai_base_url
  searxng_query_url = dependency.searxng.outputs.internal_search_url
}
