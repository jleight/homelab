variable "mise_local_config_file" {
  description = "Path of the gitignored mise local config that the terraform state credentials are written to."
  type        = string
}

variable "terraform_state_bucket_name" {
  description = "Name of the bucket holding this repository's terraform state."
  type        = string
}

variable "k8s_prod_backup_bucket_name" {
  description = "Name of the k8s prod backup bucket."
  type        = string
}
