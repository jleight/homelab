resource "b2_application_key" "terraform_state" {
  key_name   = "${var.terraform_state_bucket_name}-tfstate"
  bucket_ids = [b2_bucket.terraform_state.bucket_id]

  capabilities = [
    "deleteFiles",
    "listBuckets",
    "listFiles",
    "readFiles",
    "writeFiles"
  ]
}

# Restricted with the deprecated singular bucket_id rather than bucket_ids.
# bucket_ids produces a multi-bucket key over B2's api v4, and Backblaze limits
# those to the s3-compatible api by design: they are invisible in the web
# console and in b2_list_keys, and cannot authenticate against the native api on
# any version. UniFi Drive's backup target speaks the native api, so it can
# never connect with one. The singular field makes the provider create the key
# over native api v2 instead, which is the intended escape hatch -- see
# Backblaze/terraform-provider-b2#129.
resource "b2_application_key" "k8s_prod_backup" {
  key_name  = "${var.k8s_prod_backup_bucket_name}-nas"
  bucket_id = b2_bucket.k8s_prod_backup.bucket_id

  capabilities = [
    "deleteFiles",
    "listBuckets",
    "listFiles",
    "readFiles",
    "writeFiles"
  ]
}

# The s3 backend authenticates with AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY, and
# mise loads config.local.toml after config.toml, so what is written here
# wins over the mapping there. The whole file is managed by this resource -- hand
# edits are overwritten on the next apply.
#
# Note the circularity: this key is what grants access to the bucket holding the
# state that tracks the key. If it is ever lost or replaced outside of a clean
# apply, recover by exporting the master key as AWS_ACCESS_KEY_ID/
# AWS_SECRET_ACCESS_KEY for one run, which re-writes this file.
resource "local_sensitive_file" "mise_config" {
  filename        = var.mise_local_config_file
  file_permission = "0600"

  content = <<-TOML
    # Managed by lib/terraform/modules/backblaze/buckets. Do not edit.
    [env]
    AWS_ACCESS_KEY_ID = "${b2_application_key.terraform_state.application_key_id}"
    AWS_SECRET_ACCESS_KEY = "${b2_application_key.terraform_state.application_key}"
  TOML
}
