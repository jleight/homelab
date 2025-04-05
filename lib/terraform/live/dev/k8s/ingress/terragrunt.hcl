terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//k8s/ingress"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "secrets" {
  config_path = "../../../shared/onepassword/secrets"
}

dependency "cluster" {
  config_path = "../cluster"
}

dependencies {
  paths = ["../baseline"]
}

inputs = {
  component = "ingress"

  tailscale_operator_client_id     = dependency.secrets.outputs.tailscale_k8s_operator_client_id
  tailscale_operator_client_secret = dependency.secrets.outputs.tailscale_k8s_operator_client_secret
  cloudflare_api_token             = dependency.secrets.outputs.cloudflare_api_token
  lets_encrypt_url                 = dependency.secrets.outputs.lets_encrypt_staging_url
  lets_encrypt_email               = dependency.secrets.outputs.lets_encrypt_staging_email
  lets_encrypt_private_key         = dependency.secrets.outputs.lets_encrypt_staging_private_key

  k8s_cluster_domain = dependency.cluster.outputs.domain
}
