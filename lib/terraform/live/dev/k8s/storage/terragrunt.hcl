terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//k8s/storage"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "secrets" {
  config_path = "../../onepassword/secrets"
}

dependencies {
  paths = ["../baseline"]
}

inputs = {
  component = "storage"

  smb_nas02_username = dependency.secrets.outputs.smb_nas02_username
  smb_nas02_password = dependency.secrets.outputs.smb_nas02_password
}
