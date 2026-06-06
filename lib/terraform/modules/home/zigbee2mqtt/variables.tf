variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for the deployment. Provided by the namespace module."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the data volume."
  type        = string
}

variable "mqtt_host" {
  description = "In-cluster hostname of the MQTT broker."
  type        = string
}

variable "mqtt_port" {
  description = "Plain MQTT TCP port of the broker."
  type        = number
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

variable "zigbee2mqtt" {
  description = "Zigbee2MQTT configuration."
  type = object({
    image   = string
    version = string

    subdomain = optional(string, "zigbee")
    path      = optional(string, "/")

    device_resource = optional(string, "devices.k8s.leightha.us/zigbee")

    # yq image for the config-merge init container.
    yq = object({
      image   = string
      version = string
    })
  })
}
