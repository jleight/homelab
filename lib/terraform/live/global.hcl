inputs = {
  env_directory = get_env("ENV_DIR")

  network = {
    interface = "en0"

    gateway_ipv4 = "192.168.1.1"
    gateway_ipv6 = "fe80::74ac:b9ff:fe45:813e"
    gateway_as   = 65000

    nameservers = [
      "45.90.28.53",
      "45.90.30.53",
      "2a07:a8c0::75:ce9d",
      "2a07:a8c1::75:ce9d"
    ]
  }
}
