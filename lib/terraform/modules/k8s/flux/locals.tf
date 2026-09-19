locals {
  namespace = try(one(kubernetes_namespace_v1.this[0].metadata).name, null)

  push_enabled = local.enabled && var.k8s_flux.push != null

  github_host_keys = [for key in try(jsondecode(data.http.github_meta[0].response_body).ssh_keys, []) : key if startswith(key, "ssh-ed25519 ")]
  known_hosts      = join("\n", [for key in local.github_host_keys : "github.com ${key}"])
}
