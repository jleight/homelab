terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//k8s/flux"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../baseline"]
}

inputs = {
  component = "flux"
}
