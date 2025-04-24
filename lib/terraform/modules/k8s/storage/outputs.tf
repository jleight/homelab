output "app_data_storage_class_name" {
  value = local.enabled ? kubernetes_storage_class.longhorn_appdata[0].metadata[0].name : ""
}

output "media_storage_class_name" {
  value = local.enabled ? kubernetes_storage_class.csi_smb_nas02_media[0].metadata[0].name : ""
}
