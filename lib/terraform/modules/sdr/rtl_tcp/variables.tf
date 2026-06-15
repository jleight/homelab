variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "gateway_domain" {
  description = "Domain the LAN LoadBalancer's hostname is built under (<stack>.<domain>)."
  type        = string
}

variable "rtl_tcp" {
  description = "rtl_tcp server configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "sdr")

    device_resource = optional(string, "devices.k8s.leightha.us/rtl-sdr")
  })
}
