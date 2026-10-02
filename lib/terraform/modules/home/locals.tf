locals {
  # The broker is the mqtt HelmRelease's Service (fullnameOverride: mqtt).
  mqtt_host = "mqtt.${module.namespace.name}.svc.cluster.local"
  mqtt_port = 1883
}
