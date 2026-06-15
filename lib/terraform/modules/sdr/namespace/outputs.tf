output "namespace" {
  description = "Name of the sdr namespace."
  value       = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null
}
