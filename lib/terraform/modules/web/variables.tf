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
  })
}
