terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//apps/postgres"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  component = "postgres"
}
