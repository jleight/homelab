variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "vault" {
  description = "The name of the 1Password vault."
  type        = string
  default     = "Terraform"
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the HTTPRoute attaches to. Must be a public role — GitHub has to reach this from the internet."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
  default = []
}

variable "gateway_domain" {
  description = "Domain for the gateway ingress hostname."
  type        = string
}

variable "ghcr_deploy" {
  description = "GHCR deploy webhook configuration."
  type = object({
    # Stock Python image — the service is a single stdlib-only file mounted from
    # a ConfigMap, so there is nothing to build and no dependencies to install.
    image   = string
    version = string

    subdomain = optional(string, "cd")

    # Path the webhook is served on. Anything else 404s, signature or not.
    webhook_path = optional(string, "/webhook")

    # Optional PAT for reading private GHCR packages. Public packages resolve
    # anonymously and need nothing here.
    ghcr_token = optional(string)

    # The allowlist. Nothing is deployable that is not named here, and the
    # ServiceAccount is granted patch rights only in these namespaces (by the
    # target app's own module — the same pattern the Woodpecker deployer uses).
    # Keys are the GitHub package identity, "<owner>/<package>", lowercased,
    # which is what the webhook payload carries.
    targets = optional(map(object({
      # GHCR repository path (without the ghcr.io/ host), e.g.
      # "meshtender/meshtender".
      repository = string

      # The tag to track. A push of any tag fires the webhook, but only this
      # tag's current digest is ever deployed.
      tag = string

      namespace  = string
      deployment = string
      container  = string

      # Optional env var to set to the deployed digest ("sha256:…") alongside
      # the image, for apps that report which build they are running. Merged by
      # name, so it does not disturb the container's other env or its envFrom
      # sources.
      digest_env_var = optional(string)
    })), {})
  })
}
