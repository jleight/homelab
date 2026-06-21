terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//apps/woodpecker_ci"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

dependency "forgejo" {
  config_path = "../forgejo"
}

inputs = {
  component = "woodpecker-ci"

  namespace               = dependency.forgejo.outputs.namespace
  workspace_storage_class = dependency.k8s_storage.outputs.ephemeral_storage_class_name

  gateway_namespace = dependency.k8s_ingress.outputs.load_balancer_namespace
  gateway_name      = dependency.k8s_ingress.outputs.private_load_balancer_name
  gateway_section   = "https"
  gateway_domain    = dependency.k8s_ingress.outputs.load_balancer_domain

  forgejo_url            = dependency.forgejo.outputs.url
  forgejo_admin_username = dependency.forgejo.outputs.admin_username
  forgejo_admin_password = dependency.forgejo.outputs.admin_password

  postgres_host     = dependency.forgejo.outputs.postgres_host
  postgres_database = dependency.forgejo.outputs.woodpecker_database
  postgres_username = dependency.forgejo.outputs.woodpecker_postgres_username
  postgres_password = dependency.forgejo.outputs.woodpecker_postgres_password
}
