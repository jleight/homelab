output "tailscale_k8s_operator_client_id" {
  value = try(data.onepassword_item.tailscale_k8s_operator[0].username, null)
}

output "tailscale_k8s_operator_client_secret" {
  value     = try(data.onepassword_item.tailscale_k8s_operator[0].credential, null)
  sensitive = true
}

output "cloudflare_account_id" {
  value = try(nonsensitive(one(one([for s in data.onepassword_item.cloudflare_api_token[0].section : s if s.label == "Account"]).field).value), null)
}

output "cloudflare_api_token" {
  value     = try(data.onepassword_item.cloudflare_api_token[0].credential, null)
  sensitive = true
}

output "lets_encrypt_url" {
  value = try(data.onepassword_item.lets_encrypt[0].url, null)
}

output "lets_encrypt_email" {
  value = try(data.onepassword_item.lets_encrypt[0].username, null)
}

output "lets_encrypt_private_key" {
  value     = try(one(one([for s in data.onepassword_item.lets_encrypt[0].section : s if s.label == "Keys"]).field).value, null)
  sensitive = true
}

output "smb_nas02_username" {
  value = try(data.onepassword_item.smb_nas02[0].username, null)
}

output "smb_nas02_password" {
  value     = try(data.onepassword_item.smb_nas02[0].password, null)
  sensitive = true
}
