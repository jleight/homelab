output "url" {
  description = "Private-gateway URL of the tar1090 map."
  value       = local.enabled ? "https://${local.hostname}" : null
}

output "hostname" {
  description = "Ingress hostname for tar1090."
  value       = local.hostname
}
