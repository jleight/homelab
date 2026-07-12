terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//mesh/db"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  component = "db"

  namespace = dependency.namespace.outputs.namespace

  data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name
}
