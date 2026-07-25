output "host" {
  description = "In-cluster hostname of the broker (for mqtt:// 1883 and ws:// 8080)."
  value       = local.enabled ? "${local.name}.${local.namespace}.svc.cluster.local" : null
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
