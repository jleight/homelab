output "host" {
  description = "In-cluster hostname of the broker (for mqtt:// 1883 and ws:// 8080)."
  value       = local.enabled ? local.vernemq_host : null
}

output "users" {
  description = "Map of internal user => {username, password} for downstream consumers."
  value = local.enabled ? {
    for u in var.internal_users : u => {
      username = u
      password = local.internal_users[u]
    }
  } : {}
  sensitive = true
}

output "public_hostnames" {
  description = "Public hostnames the broker serves via the LB."
  value       = local.public_hostnames
}
