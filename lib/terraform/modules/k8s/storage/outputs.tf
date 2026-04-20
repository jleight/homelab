output "app_data_storage_class_name" {
  value = local.enabled ? kubernetes_storage_class_v1.longhorn_appdata[0].metadata[0].name : ""
}

output "media_storage_class_name" {
  value = local.enabled ? kubernetes_storage_class_v1.csi_smb_nas02_media[0].metadata[0].name : ""
}
