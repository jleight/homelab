terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//social"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  stack = "social"
}
