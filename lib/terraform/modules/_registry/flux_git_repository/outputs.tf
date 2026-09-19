output "name" {
  description = "The name of the GitRepository, and of the secret holding its deploy key."
  value       = local.name
}

output "namespace" {
  description = "The namespace the GitRepository lives in."
  value       = local.namespace
}

output "branch" {
  description = "The branch the GitRepository tracks, and that image updates are pushed to."
  value       = local.branch
}
