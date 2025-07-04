terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//apps/plex"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

inputs = {
  component = "plex"
  enabled   = false

  data_storage_class  = dependency.k8s_storage.outputs.app_data_storage_class_name
  media_storage_class = dependency.k8s_storage.outputs.media_storage_class_name
}
