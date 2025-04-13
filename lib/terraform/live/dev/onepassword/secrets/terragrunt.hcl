terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//onepassword/secrets"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  component = "secrets"

  tailscale_k8s_operator_item = "Tailscale - K8s Operator"
  cloudflare_api_token_item   = "Cloudflare - API Token"
  lets_encrypt_item           = "Let's Encrypt - Production"
  smb_nas02_item              = "SMB - nas02 - k8s-dev"
}
