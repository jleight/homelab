terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//monitoring"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../k8s/baseline"]
}

inputs = {
  stack = "monitoring"
}
