terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//home/zigbee2mqtt"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

dependency "mqtt" {
  config_path = "../mqtt"
}

inputs = {
  component = "zigbee2mqtt"

  namespace = dependency.namespace.outputs.namespace

  data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

  gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain

  mqtt_host = dependency.mqtt.outputs.host
  mqtt_port = dependency.mqtt.outputs.port
}
