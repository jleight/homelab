terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//sdr/readsb"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  component = "readsb"

  namespace = dependency.namespace.outputs.namespace
}
