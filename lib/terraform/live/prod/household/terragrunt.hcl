terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//household"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_storage" {
  config_path = "../k8s/storage"
}

dependency "k8s_ingress" {
  config_path = "../k8s/ingress"
}

inputs = {
  stack = "household"

  database_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

  database_extensions = {
    vchord = {
      renovate = "docker"
      image    = "ghcr.io/tensorchord/vchord-scratch"
      version  = "pg18-v1.1.1"
    }
  }

  immich = {
    media_storage_class = dependency.k8s_storage.outputs.media_storage_class_name

    gateway_refs   = dependency.k8s_ingress.outputs.public_https_refs
    gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain
  }

  isponsorblocktv = {
    auto_play           = false
    minimum_skip_length = 5
  }

  mealie = {
    data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

    gateway_refs   = dependency.k8s_ingress.outputs.public_https_refs
    gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain
  }

  orca_tasks = {
    attachments_storage_class = dependency.k8s_storage.outputs.backups_storage_class_name

    gateway_refs   = dependency.k8s_ingress.outputs.public_https_refs
    gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain
  }

  sure = {
    data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

    gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
    gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain

    ai = {
      base_url = "http://fwd01.leightha.us:8000/v1"
      model    = "Qwen3.6-35B-A3B-MTP-GGUF-UD-Q8_K_XL"
    }
  }
}
