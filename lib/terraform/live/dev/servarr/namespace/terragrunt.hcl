terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//servarr/namespace"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../../k8s/cluster"]
}

inputs = {
  component = "namespace"
}
