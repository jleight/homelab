variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for the deployment. Provided by the namespace module."
  type        = string
}

variable "data_storage_class" {
  description = "StorageClass for the /data volume."
  type        = string
}

variable "matter_server" {
  description = "Python Matter Server configuration."
  type = object({
    image   = string
    version = string

    storage_size = optional(string, "1Gi")

    # Pins CHIP's mDNS/link-local discovery to one host interface. Without it
    # the server listens on all interfaces — on a host-network k8s node that's
    # every Cilium veth too, which floods the logs with DNSSD parse errors. All
    # nodes use enp1s0.
    primary_interface = optional(string, "enp1s0")
  })
}
