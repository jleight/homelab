output "namespace" {
  description = "The namespace the webhook runs in."
  value       = local.namespace
}

# Target apps bind this ServiceAccount to a Role in their own namespace, so a
# compromise of the webhook can only touch Deployments that opted in.
output "service_account_name" {
  description = "The ServiceAccount the webhook patches Deployments as."
  value       = module.app.service_account_name
}

output "service_account_namespace" {
  description = "The namespace of the webhook's ServiceAccount."
  value       = local.namespace
}

output "url" {
  description = "The full payload URL to register as a GitHub webhook."
  value       = "https://${local.hostname}${var.ghcr_deploy.webhook_path}"
}

output "webhook_secret" {
  description = "The shared secret GitHub signs deliveries with. Also mirrored into 1Password."
  value       = local.webhook_secret
  sensitive   = true
}
