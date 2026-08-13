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

variable "chaptarr_service_name" {
  description = "Name of the chaptarr service."
  type        = string
}

variable "chaptarr_api_key" {
  description = "API key for the chaptarr instance."
  type        = string
  sensitive   = true
}

variable "chaptarr_url_base" {
  description = "URL base the chaptarr instance serves its API under."
  type        = string
}

variable "books_path" {
  description = "In-container path to the books library, used as the root folder."
  type        = string
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
