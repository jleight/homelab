terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//mesh/pgtt"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

dependency "woodpecker_ci" {
  config_path = "../../apps/woodpecker_ci"
}

dependency "db" {
  config_path = "../db"
}

inputs = {
  component = "pgtt"

  namespace = dependency.namespace.outputs.namespace

  gateway_refs       = dependency.k8s_ingress.outputs.public_https_refs
  gateway_domain     = dependency.k8s_ingress.outputs.load_balancer_domain
  expected_audiences = dependency.k8s_ingress.outputs.public_mqtt_hostnames

  registry_host     = dependency.woodpecker_ci.outputs.registry_host
  registry_username = dependency.woodpecker_ci.outputs.registry_username
  registry_password = dependency.woodpecker_ci.outputs.registry_password

  deployer_service_account_name      = dependency.woodpecker_ci.outputs.deployer_service_account_name
  deployer_service_account_namespace = dependency.woodpecker_ci.outputs.namespace

  db_host     = dependency.db.outputs.host
  db_port     = dependency.db.outputs.port
  db_username = dependency.db.outputs.pgtt_username
  db_password = dependency.db.outputs.pgtt_password
}
