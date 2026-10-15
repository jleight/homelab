output "name" {
  description = "The name of the namespace."
  value       = local.namespace
}

output "registry_secret_name" {
  description = "Name of the dockerconfigjson Secret for the in-cluster image registry."
  value       = module.image_build.secret_name
}

output "registry_image_prefix" {
  description = "Registry host and namespace that ImageBuilds in this namespace name their images under."
  value       = module.image_build.image_prefix
}
