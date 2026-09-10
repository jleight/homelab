output "s3_endpoint" {
  description = "Base URL for s3-compatible API calls."
  value       = data.b2_account_info.current.s3_api_url
}

output "s3_region" {
  description = "Region to pair with the s3 endpoint."
  value       = local.s3_region
}

output "k8s_prod_backup_bucket_name" {
  description = "Name of the k8s prod backup bucket."
  value       = b2_bucket.k8s_prod_backup.bucket_name
}

output "k8s_prod_backup_key_id" {
  description = "Application key id for the NAS backup job."
  value       = b2_application_key.k8s_prod_backup.application_key_id
}

output "k8s_prod_backup_key" {
  description = "Application key for the NAS backup job."
  value       = b2_application_key.k8s_prod_backup.application_key
  sensitive   = true
}
