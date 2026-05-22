terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//mesh/mqtt"
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

inputs = {
  component = "mqtt"

  namespace = dependency.namespace.outputs.namespace

  gateway_namespace      = dependency.k8s_ingress.outputs.load_balancer_namespace
  gateway_name           = dependency.k8s_ingress.outputs.public_load_balancer_name
  mqtt_gateway_listeners = dependency.k8s_ingress.outputs.public_load_balancer_mqtt_listeners
}
