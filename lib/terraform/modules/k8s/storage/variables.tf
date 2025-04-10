variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "smb_nas02_url" {
  description = "SMB URL for NAS02."
  type        = string
}

variable "smb_nas02_username" {
  description = "Username for NAS02."
  type        = string
}

variable "smb_nas02_password" {
  description = "Password for NAS02."
  type        = string
  sensitive   = true
}

variable "k8s_storage" {
  description = "Settings for Kubernetes cluster storage."
  type = object({
    longhorn = object({
      repository = string
      chart      = string
      version    = string
      enabled    = optional(bool, true)
    })

    longhorn_test = optional(object({
      image   = string
      version = string
    }), null)

    openebs = object({
      repository = string
      chart      = string
      version    = string
      enabled    = optional(bool, true)
    })

    openebs_test = optional(object({
      image   = string
      version = string
    }), null)

    csi_smb = object({
      repository = string
      chart      = string
      version    = string
      enabled    = optional(bool, true)
    })

    csi_smb_test = optional(object({
      image   = string
      version = string
    }), null)
  })
}
