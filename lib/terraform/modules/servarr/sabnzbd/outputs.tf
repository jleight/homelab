output "service_name" {
  value = module.app.service_name
}

output "api_key" {
  value     = local.enabled ? random_bytes.api_key[0].hex : ""
  sensitive = true
}
