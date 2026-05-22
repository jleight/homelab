output "vernemq_host" {
  description = "In-cluster hostname of the CoreScope VerneMQ broker."
  value       = local.enabled ? local.vernemq_host : null
}

output "vernemq_meshbug_username" {
  description = "Internal VerneMQ username allocated for MeshBug."
  value       = local.enabled ? local.vernemq_meshbug_user : null
}

output "vernemq_meshbug_password" {
  description = "Internal VerneMQ password allocated for MeshBug."
  value       = local.enabled ? local.vernemq_meshbug_pass : null
  sensitive   = true
}
