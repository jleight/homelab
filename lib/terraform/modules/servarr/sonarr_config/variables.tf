variable "env_directory" {
  description = "Path to the env directory."
  type        = string
}

variable "vault" {
  description = "The name of the vault."
  type        = string
  default     = "Terraform"
}

variable "namespace" {
  description = "Namespace for the deployment."
  type        = string
}

variable "sonarr_service_name" {
  description = "Name of the sonarr service."
  type        = string
}

variable "sonarr_api_key" {
  description = "API key for the sonarr instance."
  type        = string
  sensitive   = true
}

variable "sabnzbd_service_name" {
  description = "Name of the sabnzbd service."
  type        = string
}

variable "sabnzbd_api_key" {
  description = "API key for the sabnzbd instance."
  type        = string
  sensitive   = true
}

variable "qbittorrent_service_name" {
  description = "Name of the qbittorrent service."
  type        = string
}

variable "qbittorrent_username" {
  description = "Username for the qbittorrent instance."
  type        = string
}

variable "qbittorrent_password" {
  description = "Password for the qbittorrent instance."
  type        = string
  sensitive   = true
}

variable "plex_namespace" {
  description = "Namespace for the plex deployment."
  type        = string
}

variable "plex_service_name" {
  description = "Name of the plex service."
  type        = string
}

variable "plex_port" {
  description = "Plex port."
  type        = number
}
