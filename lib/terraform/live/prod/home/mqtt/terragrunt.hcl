terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//home/mqtt"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  component = "mqtt"

  namespace = dependency.namespace.outputs.namespace
}
