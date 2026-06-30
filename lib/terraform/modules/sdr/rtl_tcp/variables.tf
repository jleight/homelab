variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "rtl_tcp" {
  description = "rtl_tcp server configuration."
  type = object({
    image   = string
    version = string

    # Expose rtl_tcp as a dedicated tailnet device (via the Tailscale operator's
    # loadBalancerClass) so an off-LAN client — e.g. the iOS rtl_tcp app — can
    # reach it by a stable Tailscale IP / MagicDNS name from anywhere. When false
    # it falls back to a LAN-only Cilium LB-IPAM VIP.
    tailscale = optional(bool, true)

    # Tailscale device hostname for the LB. Defaults to "<component>-<environment>".
    tailscale_hostname = optional(string)

    device_resource = optional(string, "devices.k8s.leightha.us/sdr-shortwave")
  })
}
