output "host" {
  description = "In-cluster hostname of the broker (mqtt:// on 1883)."
  value       = local.enabled ? local.vernemq_host : null
}

output "port" {
  description = "The plain MQTT TCP port."
  value       = local.vernemq_mqtt_port
}
