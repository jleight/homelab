variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for the deployment. Provided by the namespace module."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the store volume."
  type        = string
}

variable "gateway_namespace" {
  description = "Namespace for the gateway for private ingress."
  type        = string
}

variable "gateway_name" {
  description = "Name of the gateway for private ingress."
  type        = string
}

variable "gateway_section" {
  description = "Name of the gateway section for private ingress."
  type        = string
}

variable "gateway_domain" {
  description = "Domain for the gateway for private ingress."
  type        = string
}

variable "zwave_js_ui" {
  description = "Z-Wave JS UI configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "zwave")
    path      = optional(string, "/")

    device_resource = optional(string, "devices.k8s.leightha.us/zwave")

    # yq image for the settings-merge init container.
    yq = object({
      image   = string
      version = string
    })
  })
}
