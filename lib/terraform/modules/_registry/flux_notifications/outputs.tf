output "secret_name" {
  description = "Secret the namespace's Flux Provider reads its webhook address from."
  value       = local.enabled ? kubernetes_secret_v1.discord[0].metadata[0].name : ""
}
