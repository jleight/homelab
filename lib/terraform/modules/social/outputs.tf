output "matrix_server_name" {
  description = "The Matrix server name (the domain part of user IDs)."
  value       = local.synapse_server_name
}

output "matrix_client_base_url" {
  description = "The homeserver's public client-server API base URL."
  value       = "https://${local.synapse_domain}"
}
