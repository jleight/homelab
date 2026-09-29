locals {
  github_proxy_domain = "${var.github_proxy.subdomain}.${var.github_proxy.gateway_domain}"
}
