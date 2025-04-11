locals {
  readme_inputs   = yamldecode(trim(regex("---\r?\n(?s:.+)\r?\n---", file(find_in_parent_folders("README.md"))), "---"))
  global_hcl      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  environment_hcl = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  stack_hcl       = read_terragrunt_config(find_in_parent_folders("stack.hcl"))

  state_key = format(
    "%s/%s/%s",
    lower(local.readme_inputs.repository),
    path_relative_to_include(),
    "terraform.tfstate"
  )
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.g.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    region   = "us-east-1"
    endpoint = "https://${get_env("B2_TF_BUCKET_ENDPOINT")}"
    bucket   = get_env("B2_TF_BUCKET_NAME")
    key      = local.state_key
    #use_lockfile = true

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

inputs = merge(
  local.readme_inputs,
  local.global_hcl.inputs,
  local.environment_hcl.inputs,
  local.stack_hcl.inputs
)
