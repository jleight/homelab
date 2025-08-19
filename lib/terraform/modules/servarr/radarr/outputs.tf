output "service_name" {
  value = local.service_name
}

output "url" {
  value = local.enabled ? "https://${local.hostname}${local.path}" : ""
}

output "api_key" {
  value     = local.enabled ? replace(random_uuid.api_key[0].result, "-", "") : ""
  sensitive = true
}
