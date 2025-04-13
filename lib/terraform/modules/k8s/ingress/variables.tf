variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "network" {
  description = "Settings for the home network."
  type = object({
    interface    = string
    gateway_ipv4 = string
    gateway_ipv6 = string
    gateway_as   = number
    nameservers  = set(string)
  })
}

variable "tailscale_operator_client_id" {
  description = "Client ID for the Tailscale Operator."
  type        = string
}

variable "tailscale_operator_client_secret" {
  description = "Client secret for the Tailscale Operator."
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Token for managing DNS in Cloudflare."
  type        = string
  sensitive   = true
}

variable "lets_encrypt_url" {
  description = "URL for Let's Encrypt."
  type        = string
}

variable "lets_encrypt_email" {
  description = "Email for Let's Encrypt."
  type        = string
}

variable "lets_encrypt_private_key" {
  description = "Private key for Let's Encrypt."
  type        = string
  sensitive   = true
  default     = null
}

variable "k8s_cluster_domain" {
  description = "Domain for the Kubernetes cluster."
  type        = string
}

variable "k8s_ingress" {
  description = "Settings for Kubernetes cluster ingress."
  type = object({
    tailscale = object({
      repository = string
      chart      = string
      version    = string
      enabled    = optional(bool, true)
    })

    external_dns = object({
      repository = string
      chart      = string
      version    = string
      enabled    = optional(bool, true)
    })

    cert_manager = object({
      repository = string
      chart      = string
      version    = string
      enabled    = optional(bool, true)
    })

    cert_manager_test = optional(object({
      enabled = bool
    }), null)

    load_balancer = optional(object({
      enabled = optional(bool, true)
      bgp_asn = optional(number, 0)
    }), {})
  })
}
