inputs = {
  stack = "home"

  esphome = {
    renovate = "docker"
    image    = "ghcr.io/esphome/esphome"
    version  = "2026.5"
  }

  mqtt = {
    renovate   = "helm"
    repository = "https://vernemq.github.io/docker-vernemq"
    chart      = "vernemq"
    version    = "2.1.2"
  }
}
