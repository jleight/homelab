output "namespace" {
  description = "Namespace Woodpecker runs in, and where pipeline step pods are created."
  value       = local.namespace
}

output "deployer_service_account_name" {
  description = "ServiceAccount name CD steps run as; bind it in each app's namespace to allow deploys."
  value       = local.deployer_service_account
}

output "registry_host" {
  description = "Host of the Forgejo OCI registry images are pushed to and pulled from."
  value       = local.registry_host
}

output "registry_username" {
  description = "Username of the CI bot used for registry auth."
  value       = local.ci_username
}

output "registry_password" {
  description = "Password of the CI bot used for registry auth (build a dockerconfigjson pull secret per app namespace)."
  value       = local.ci_password
  sensitive   = true
}
