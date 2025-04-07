terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//k8s/cluster"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "secrets" {
  config_path = "../../onepassword/secrets"
}

inputs = {
  component = "cluster"

  cloudflare_api_token = dependency.secrets.outputs.cloudflare_api_token
}
