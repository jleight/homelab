terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//k8s/storage"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "secrets" {
  config_path = "../../onepassword/secrets"
}

dependency "k8s_ingress" {
  config_path = "../ingress"
}

dependencies {
  paths = ["../baseline"]
}

inputs = {
  component = "storage"

  smb_nas02_username = dependency.secrets.outputs.smb_nas02_username
  smb_nas02_password = dependency.secrets.outputs.smb_nas02_password

  gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain
}
