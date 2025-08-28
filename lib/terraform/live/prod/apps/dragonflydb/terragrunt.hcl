terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//apps/dragonflydb"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  component = "dragonflydb"
}
