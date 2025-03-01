locals {
  readme_inputs   = yamldecode(trim(regex("---\r?\n(?s:.+)\r?\n---", file(find_in_parent_folders("README.md"))), "---"))
  global_hcl      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  environment_hcl = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  stack_hcl       = read_terragrunt_config(find_in_parent_folders("stack.hcl"))

  state_path = format(
    "%s/%s/%s/%s",
    get_env("TF_STATE_ROOT", "/Volumes/Terraform"),
    lower(local.readme_inputs.repository),
    path_relative_to_include(),
    "terraform.tfstate"
  )
}

remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path = local.state_path
  }
}

terraform {
  extra_arguments "skip_lock" {
    commands = [
      "init",
      "apply",
      "refresh",
      "import",
      "plan",
      "taint",
      "untaint"
    ]

    arguments = [
      "-lock=false"
    ]
  }
}


inputs = merge(
  local.readme_inputs,
  local.global_hcl.inputs,
  local.environment_hcl.inputs,
  local.stack_hcl.inputs
)
