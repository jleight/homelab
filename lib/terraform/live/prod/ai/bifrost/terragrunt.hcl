terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//ai/bifrost"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "db" {
  config_path = "../db"
}

inputs = {
  component = "bifrost"

  namespace = dependency.namespace.outputs.name

  gateway_refs   = dependency.k8s_ingress.outputs.public_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain

  db_host     = dependency.db.outputs.host
  db_port     = dependency.db.outputs.port
  db_username = dependency.db.outputs.bifrost_username
  db_password = dependency.db.outputs.bifrost_password
}
