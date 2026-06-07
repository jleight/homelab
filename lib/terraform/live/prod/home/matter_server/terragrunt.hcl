terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//home/matter_server"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

inputs = {
  component = "matter-server"

  namespace = dependency.namespace.outputs.namespace

  data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name
}
