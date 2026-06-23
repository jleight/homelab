terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//sdr/rtl_tcp"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  component = "rtl-tcp"

  namespace = dependency.namespace.outputs.namespace
}
