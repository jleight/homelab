terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//home/namespace"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  component = "home"
}
