output "host" {
  value = local.enabled ? "${local.name}-rw.${local.namespace}.svc.cluster.local" : null
}

output "port" {
  value = 5432
}
