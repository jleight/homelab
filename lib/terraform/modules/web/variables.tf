variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "apex" {
  description = "Settings for the zone-apex site (<domain> and www.<domain>)."
  type = object({
    apex_gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    www_gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string

    # Everything outside /.well-known/ is redirected here.
    redirect_hostname = string

    # Published at /.well-known/matrix/client so @user:<domain> IDs find the
    # homeserver.
    matrix_client_base_url = string
  })
}

variable "github_proxy" {
  description = "Settings for the token-injecting GitHub API proxy Obtainium uses."
  type = object({
    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "github-proxy")

    # API Credential item holding a no-permission, public-repos-only
    # fine-grained PAT.
    token_item = optional(string, "GitHub - Proxy Token")
  })
}

variable "homepage" {
  description = "Settings for the Homepage service dashboard."
  type = object({
    gateway_refs = list(object({
      namespace   = string
      name        = string
      sectionName = string
    }))
    gateway_domain = string
    subdomain      = optional(string, "dash")
  })
}
