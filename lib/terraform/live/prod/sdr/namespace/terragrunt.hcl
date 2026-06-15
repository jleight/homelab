terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//sdr/namespace"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../../k8s/cluster"]
}

inputs = {
  component = "sdr"
}
