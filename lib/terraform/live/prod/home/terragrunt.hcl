terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//home"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_storage" {
  config_path = "../k8s/storage"
}

inputs = {
  stack = "home"

  database_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name
  data_storage_class     = dependency.k8s_storage.outputs.app_data_storage_class_name
}
