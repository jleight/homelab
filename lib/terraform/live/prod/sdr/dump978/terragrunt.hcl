terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//sdr/dump978"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  component = "dump978"

  namespace = dependency.namespace.outputs.namespace
}
