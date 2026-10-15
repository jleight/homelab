output "secret_name" {
  description = "Name of the dockerconfigjson Secret for the registry."
  value       = local.enabled ? kubernetes_secret_v1.this[0].metadata[0].name : null
}

output "image_prefix" {
  description = "Registry host and namespace that images built in this namespace are named under, such as registry.example.com/home."
  value       = local.enabled ? "${local.registry_host}/${var.namespace}" : null
}
