variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "database_storage_class" {
  description = "StorageClass for the namespace-wide database cluster's volumes."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the apps' data volumes."
  type        = string
}

variable "backups_storage_class" {
  description = "SMB-backed StorageClass for Home Assistant's backup target on nas02."
  type        = string
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the apps' HTTPRoutes attach to."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
}

variable "gateway_domain" {
  description = "Domain for the gateway for private ingress."
  type        = string
}

variable "esphome" {
  description = "Settings for ESPHome's Terraform-owned resources."
  type = object({
    subdomain = optional(string, "esphome")
  })
  default = {}
}

variable "home_assistant" {
  description = "Settings for Home Assistant's Terraform-owned resources."
  type = object({
    subdomain = optional(string, "home-internal")
  })
  default = {}
}

variable "zigbee2mqtt" {
  description = "Settings for Zigbee2MQTT's Terraform-owned resources."
  type = object({
    subdomain = optional(string, "zigbee")
  })
  default = {}
}

variable "zwave_js_ui" {
  description = "Settings for Z-Wave JS UI's Terraform-owned resources."
  type = object({
    subdomain = optional(string, "zwave")
  })
  default = {}
}
