output "name" {
  value = local.enabled ? kubernetes_namespace.this[0].metadata[0].name : ""
}
