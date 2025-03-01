output "kubeconfig_file" {
  value = replace(local.kubeconfig_file, "/", "//")
}
