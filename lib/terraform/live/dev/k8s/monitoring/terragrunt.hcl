terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//k8s/monitoring"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../cluster", "../baseline"]
}

inputs = {
  component = "monitoring"
}
