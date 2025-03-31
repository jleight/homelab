output "cloudflare_api_token" {
  value     = try(data.onepassword_item.cloudflare_api_token[0].credential, null)
  sensitive = true
}

output "smb_nas02_username" {
  value = try(data.onepassword_item.smb_nas02[0].username, null)
}

output "smb_nas02_password" {
  value     = try(data.onepassword_item.smb_nas02[0].password, null)
  sensitive = true
}

output "lets_encrypt_staging_url" {
  value = try(data.onepassword_item.lets_encrypt_staging[0].url, null)
}

output "lets_encrypt_staging_email" {
  value = try(data.onepassword_item.lets_encrypt_staging[0].username, null)
}

output "lets_encrypt_staging_private_key" {
  value     = try(one(one([for s in data.onepassword_item.lets_encrypt_staging[0].section : s if s.label == "Keys"]).field).value, null)
  sensitive = true
}

output "lets_encrypt_production_url" {
  value = try(data.onepassword_item.lets_encrypt_production[0].url, null)
}

output "lets_encrypt_production_email" {
  value = try(data.onepassword_item.lets_encrypt_production[0].username, null)
}

output "lets_encrypt_production_private_key" {
  value     = try(one(one([for s in data.onepassword_item.lets_encrypt_production[0].section : s if s.label == "Keys"]).field).value, null)
  sensitive = true
}
