terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//apps/isponsorblocktv"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "secrets" {
  config_path = "../../onepassword/secrets"
}

dependencies {
  paths = ["../../k8s/cluster"]
}

inputs = {
  component = "isponsorblocktv"

  youtube_screen_id_apple_tv_4k = dependency.secrets.outputs.youtube_screen_id_apple_tv_4k
}
