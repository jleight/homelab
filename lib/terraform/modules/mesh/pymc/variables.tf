variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace for pyMC_Repeater. Provided by the mesh namespace module."
  type        = string
}

variable "vault" {
  description = "The name of the 1Password vault."
  type        = string
  default     = "Terraform"
}

variable "share_storage_class" {
  description = "StorageClass for the NAS share PVC (SMB). Holds the persisted config (config/) and the Litestream SQLite replica (backup/). Must be RWX so the pod can reschedule onto either modem node."
  type        = string
}

variable "share_storage_size" {
  description = "Size of the NAS share PVC."
  type        = string
  default     = "10Gi"
}

variable "gateway_namespace" {
  description = "Namespace for the gateway for ingress."
  type        = string
}

variable "gateway_name" {
  description = "Name of the (private) gateway for ingress."
  type        = string
}

variable "gateway_section" {
  description = "Name of the gateway section/listener for ingress."
  type        = string
}

variable "gateway_domain" {
  description = "Domain for the gateway for ingress."
  type        = string
}

variable "pymc" {
  description = "pyMC_Repeater configuration."
  type = object({
    image   = string
    version = string
    digest  = string

    # Extended resource advertised by the generic-device-plugin for the KISS
    # modem. Requesting it makes the scheduler place the pod on the node that has
    # the modem (and injects the device).
    device_resource = optional(string, "devices.k8s.leightha.us/meshcore")

    # In-container serial device path. Must match the device-plugin mountPath.
    serial_port = optional(string, "/dev/ttyUSB0")
    baud_rate   = optional(number, 115200)

    subdomain = optional(string, "pymc")

    # Litestream sidecar/init image, used to stream the SQLite WAL to the NAS.
    litestream = object({
      image   = string
      version = string
    })

    # Base TCP port for companions; each companion gets companion_port_base + its
    # index in the list. Append new companions to the END to keep existing ports
    # stable (clients connect to a specific port).
    companion_port_base = optional(number, 8531)

    # Expose the companions LoadBalancer as a dedicated tailnet device (via the
    # Tailscale operator's loadBalancerClass) so clients can connect by a stable
    # Tailscale IP from anywhere. When false, it's a LAN-only Cilium LB-IPAM VIP.
    companions_tailscale = optional(bool, true)

    # Tailscale device hostname for the companions LB. Defaults to
    # "<component>-companions-<environment>".
    companions_hostname = optional(string)

    # Companions emulate MeshCore companion radios; each runs a TCP frame server
    # (in the one repeater pod) that clients connect to, exposed via the shared
    # LoadBalancer. identity_key (hex) and tcp_port are generated, not specified.
    companions = optional(list(object({
      name      = string
      node_name = optional(string)
    })), [])

    # Room servers are MeshCore chat-room identities reached over RF via the
    # repeater (no TCP port to expose). identity_key (hex) is generated; the
    # admin/guest passwords are read from the "pyMC Room Server - {name}"
    # 1Password item.
    room_servers = optional(list(object({
      name      = string
      node_name = optional(string)
      latitude  = optional(number)
      longitude = optional(number)
    })), [])
  })
}
