terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//onepassword/secrets"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  component = "secrets"
}
