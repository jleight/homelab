variable "name" {
  description = "Name for the application. Defaults to the component name from context."
  type        = string
  default     = null
}

variable "app_component" {
  description = "Value for the app.kubernetes.io/component label."
  type        = string
  default     = null
}

# ──────────────────────────────────────────────────────────────────────────────
# Namespace
# ──────────────────────────────────────────────────────────────────────────────

variable "namespace" {
  description = "Namespace for the deployment. Required when create_namespace is false."
  type        = string
}

# ──────────────────────────────────────────────────────────────────────────────
# Image
# ──────────────────────────────────────────────────────────────────────────────

variable "image" {
  description = "Container image (without tag)."
  type        = string
}

variable "image_version" {
  description = "Container image tag/version."
  type        = string
}

variable "image_digest" {
  description = "Optional image digest (e.g. sha256:...) to pin alongside the tag. The tag is still used for the version label."
  type        = string
  default     = null
}

# ──────────────────────────────────────────────────────────────────────────────
# Deployment
# ──────────────────────────────────────────────────────────────────────────────

variable "pod_annotations" {
  description = "Annotations to add to the pod template."
  type        = map(string)
  default     = {}
}

variable "replicas" {
  description = "Number of deployment replicas."
  type        = number
  default     = 1
}

variable "port" {
  description = "Primary container port. Null for outbound-only workloads with no listener (also set create_service = false)."
  type        = number
  default     = null
}

variable "create_service" {
  description = "Whether to create a ClusterIP Service. Disable for purely outbound daemons (e.g. a recorder) that expose no port."
  type        = bool
  default     = true
}

variable "host_network" {
  description = "Whether to use host networking."
  type        = bool
  default     = false
}

variable "dns_policy" {
  description = "Pod dnsPolicy. Defaults to ClusterFirstWithHostNet when host_network is true (so cluster DNS still works), else ClusterFirst."
  type        = string
  default     = null
}

variable "deployment_strategy" {
  description = "Deployment update strategy: \"RollingUpdate\" (default) or \"Recreate\". Use Recreate for apps holding a single exclusive resource (e.g. a host device) where surging a second pod would deadlock the rollout."
  type        = string
  default     = "RollingUpdate"

  validation {
    condition     = contains(["RollingUpdate", "Recreate"], var.deployment_strategy)
    error_message = "deployment_strategy must be either \"RollingUpdate\" or \"Recreate\"."
  }
}

variable "enable_service_links" {
  description = "Whether to inject Kubernetes service discovery env vars (SVCNAME_*) into the container. Disable for apps whose own config env vars collide with these (e.g. OctoPrint reads OCTOPRINT_PORT)."
  type        = bool
  default     = true
}

# Pod-level securityContext. All default to null, which omits the block entirely
# (no change for existing apps). Set fs_group for non-root images that write to a
# PVC: the kubelet chowns the volume to that group on mount and makes it
# group-writable, so the process can write without an in-image or init-container
# chown.
variable "fs_group" {
  description = "Pod securityContext fsGroup. Set for non-root apps that write to a mounted volume."
  type        = number
  default     = null
}

variable "run_as_user" {
  description = "Pod securityContext runAsUser."
  type        = number
  default     = null
}

variable "run_as_non_root" {
  description = "Pod securityContext runAsNonRoot."
  type        = bool
  default     = null
}

variable "command" {
  description = "Command (entrypoint) for the main container. Overrides (fully replaces) the image's ENTRYPOINT. Empty leaves the image entrypoint intact."
  type        = list(string)
  default     = []
}

variable "args" {
  description = "Args for the main container. Overrides (fully replaces) the image's default CMD, leaving the entrypoint intact. Include any image defaults you still need."
  type        = list(string)
  default     = []
}

variable "env" {
  description = "Map of environment variables for the main container."
  type        = map(string)
  default     = {}
}

variable "env_from_config_maps" {
  description = "List of ConfigMap names to load as env vars."
  type        = list(string)
  default     = []
}

variable "env_from_secrets" {
  description = "List of Secret names to load as env vars."
  type        = list(string)
  default     = []
}

variable "secret_env" {
  description = "Map of environment variables sourced from secrets. Key is the env var name, value is an object with secret name and key."
  type = map(object({
    secret_name = string
    key         = string
  }))
  default = {}
}

variable "resource_limits" {
  description = "Resource limits for the main container."
  type        = map(string)
  default     = {}
}

variable "resource_requests" {
  description = "Resource requests for the main container."
  type        = map(string)
  default     = {}
}

variable "volume_mounts" {
  description = "Volume mounts for the main container."
  type = list(object({
    name       = string
    mount_path = string
    sub_path   = optional(string)
    read_only  = optional(bool, false)
  }))
  default = []
}

variable "volumes_from_pvcs" {
  description = "Map of volume name to PVC claim name."
  type        = map(string)
  default     = {}
}

variable "volumes_from_config_maps" {
  description = "Map of volume name to ConfigMap name."
  type        = map(string)
  default     = {}
}

variable "volumes_from_secrets" {
  description = "Map of volume name to Secret name."
  type        = map(string)
  default     = {}
}

variable "volumes_empty_dir" {
  description = "List of volume names backed by emptyDir."
  type        = list(string)
  default     = []
}

variable "init_containers" {
  description = "Init containers to add to the deployment."
  type = list(object({
    name        = string
    image       = optional(string)
    command     = optional(list(string))
    run_as_user = optional(number)
    volume_mounts = optional(list(object({
      name       = string
      mount_path = string
      sub_path   = optional(string)
      read_only  = optional(bool, false)
    })), [])
  }))
  default = []
}

variable "extra_containers" {
  description = "Additional sidecar containers."
  type = list(object({
    name                 = string
    image                = string
    port                 = optional(number)
    env                  = optional(map(string), {})
    env_from_config_maps = optional(list(string), [])
    env_from_secrets     = optional(list(string), [])
    volume_mounts = optional(list(object({
      name       = string
      mount_path = string
      sub_path   = optional(string)
      read_only  = optional(bool, false)
    })), [])
  }))
  default = []
}

# ──────────────────────────────────────────────────────────────────────────────
# Service
# ──────────────────────────────────────────────────────────────────────────────

variable "service_port" {
  description = "The port exposed by the Service (defaults to 80)."
  type        = number
  default     = 80
}

variable "extra_service_ports" {
  description = "Additional ports to expose on the service."
  type = list(object({
    name        = string
    port        = number
    target_port = number
  }))
  default = []
}

# ──────────────────────────────────────────────────────────────────────────────
# Ingress
# ──────────────────────────────────────────────────────────────────────────────

variable "ingress_enabled" {
  description = "Whether to create an HTTPRoute ingress."
  type        = bool
  default     = true
}

variable "gateway_refs" {
  description = "Gateway API parentRefs the HTTPRoute attaches to. Splatted straight into spec.parentRefs; sourced from a k8s/ingress *_refs output."
  type = list(object({
    namespace   = string
    name        = string
    sectionName = string
  }))
  default = []
}

variable "gateway_domain" {
  description = "Domain for the gateway ingress hostname."
  type        = string
  default     = null
}

variable "subdomain" {
  description = "Subdomain for the ingress hostname."
  type        = string
  default     = null
}

variable "path" {
  description = "Path prefix for the ingress rule."
  type        = string
  default     = "/"
}

variable "ingress_extra_rules" {
  description = "Additional raw HTTPRoute rules to append (list of rule objects)."
  type        = any
  default     = []
}

# ──────────────────────────────────────────────────────────────────────────────
# Persistent Volume Claims
# ──────────────────────────────────────────────────────────────────────────────

variable "persistent_volume_claims" {
  description = "Map of PVC key to configuration. Each PVC is created and its name is available in outputs."
  type = map(object({
    storage_class = string
    storage_size  = optional(string, "1Gi")
    access_modes  = optional(list(string), ["ReadWriteMany"])
  }))
  default = {}
}

# ──────────────────────────────────────────────────────────────────────────────
# Postgres Cluster
# ──────────────────────────────────────────────────────────────────────────────

variable "postgres_enabled" {
  description = "Whether to create a CNPG Postgres cluster for this app."
  type        = bool
  default     = false
}

variable "postgres_storage_class" {
  description = "StorageClass for the database PVCs."
  type        = string
  default     = null
}

variable "postgres_storage_size" {
  description = "Storage size for the database PVCs."
  type        = string
  default     = "1Gi"
}

variable "postgres_instances" {
  description = "Number of CNPG instances."
  type        = number
  default     = 2
}

variable "postgres_image_name" {
  description = "Custom container image for the CNPG cluster. If null, uses the CNPG operator default."
  type        = string
  default     = null
}

variable "postgres_shared_preload_libraries" {
  description = "List of shared_preload_libraries for the PostgreSQL configuration."
  type        = list(string)
  default     = []
}

variable "postgres_post_init_sql" {
  description = "List of SQL statements to run after initdb."
  type        = list(string)
  default     = []
}

variable "postgres_extra_secret_data" {
  description = "Additional key/value pairs to include in the Kubernetes secret."
  type        = map(string)
  default     = {}
}

variable "postgres_env_vars" {
  description = "Map of env var names to postgres connection fields to inject into the main container. Supported fields: host, port, username, database."
  type        = map(string)
  default     = {}
}

variable "postgres_secret_env_vars" {
  description = "Map of env var names to postgres secret keys to inject into the main container."
  type        = map(string)
  default     = {}
}

variable "postgres_database" {
  description = "Database name used in the postgres_env_vars 'database' field."
  type        = string
  default     = "app"
}

variable "postgres_url_scheme" {
  description = "URL scheme for the generated connection string (e.g. \"postgresql\", or \"postgresql+psycopg\" for SQLAlchemy psycopg3 apps)."
  type        = string
  default     = "postgres"
}
