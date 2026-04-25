inputs = {
  env_directory = get_env("ENV_DIR")
  username      = get_env("USER")
  k8s_version   = "1.36.0"

  network = {
    interface = "en0"

    nameservers = [
      "45.90.28.53",
      "45.90.30.53",
      "2a07:a8c0::75:ce9d",
      "2a07:a8c1::75:ce9d"
    ]

    gateway_as = 65000
  }

  ddns_host     = "ddns.jleight.com"
  smb_nas02_url = "//192.168.1.251"
}
