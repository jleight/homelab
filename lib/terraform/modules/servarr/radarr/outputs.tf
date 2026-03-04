output "service_name" {
  value = module.app.service_name
}

output "url" {
  value = module.app.url
}

output "api_key" {
  value     = local.enabled ? replace(random_uuid.api_key[0].result, "-", "") : ""
  sensitive = true
}
