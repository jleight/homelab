inputs = {
  env_directory = get_env("ENV_DIR")

  network = {
    interface = "en0"
    subnet    = "192.168.1.0/24"

    ip_offsets = {
      gateway = 1
    }

    nameservers = [
      "45.90.28.53",
      "45.90.30.53"
    ]
  }
}
