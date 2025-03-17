terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//k8s/cluster"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  component = "cluster"
}
