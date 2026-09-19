output "namespace" {
  description = "Namespace the Flux controllers run in."
  value       = local.namespace
}

output "sync_path" {
  description = "Repository path the root Flux Kustomization reconciles."
  value       = var.k8s_flux.sync.path
}
