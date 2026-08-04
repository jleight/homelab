terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//mesh/beacon"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "db" {
  config_path = "../db"
}

dependency "mqtt" {
  config_path = "../mqtt"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

inputs = {
  component = "beacon"

  namespace = dependency.namespace.outputs.namespace

  gateway_refs   = dependency.k8s_ingress.outputs.public_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain

  db_host     = dependency.db.outputs.host
  db_port     = dependency.db.outputs.port
  db_username = dependency.db.outputs.beacon_username
  db_password = dependency.db.outputs.beacon_password

  vernemq_host     = dependency.mqtt.outputs.host
  vernemq_username = dependency.mqtt.outputs.users.beacon.username
  vernemq_password = dependency.mqtt.outputs.users.beacon.password
}
