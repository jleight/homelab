locals {
  github_proxy_domain = "${var.github_proxy.subdomain}.${var.github_proxy.gateway_domain}"
  homepage_domain     = "${var.homepage.subdomain}.${var.homepage.gateway_domain}"
}
