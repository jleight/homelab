variable "github_repository_full_name" {
  description = "Owner and name of the GitHub repository, as \"owner/name\". Set only by the stack that creates the GitRepository; leaving it null makes the module report where the GitRepository lives without creating it."
  type        = string
  default     = null
}
