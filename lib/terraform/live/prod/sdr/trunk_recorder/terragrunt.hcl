terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//sdr/trunk_recorder"
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
  component = "trunk-recorder"

  namespace = dependency.namespace.outputs.namespace

  media_storage_class = dependency.k8s_storage.outputs.media_storage_class_name
}
