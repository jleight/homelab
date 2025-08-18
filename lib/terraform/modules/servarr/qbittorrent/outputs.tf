output "service_name" {
  value = local.service_name
}

output "username" {
  value = local.qbittorrent_username
}

output "password" {
  value     = local.qbittorrent_password
  sensitive = true
}
