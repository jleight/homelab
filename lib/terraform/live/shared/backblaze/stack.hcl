inputs = {
  stack = "backblaze"

  mise_local_config_file      = get_env("MISE_LOCAL_CONFIG_FILE")
  terraform_state_bucket_name = get_env("B2_TF_BUCKET_NAME")
  k8s_prod_backup_bucket_name = "jleight-k8s-prod-backup"
}
