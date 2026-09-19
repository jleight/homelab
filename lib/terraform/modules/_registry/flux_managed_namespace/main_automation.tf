resource "kubectl_manifest" "image_automation" {
  count = local.enabled ? 1 : 0

  server_side_apply = true

  yaml_body = yamlencode({
    apiVersion = "image.toolkit.fluxcd.io/v1"
    kind       = "ImageUpdateAutomation"

    metadata = {
      namespace = local.namespace
      name      = "images"
    }

    spec = {
      interval = "30m"

      sourceRef = {
        kind      = "GitRepository"
        namespace = module.git_repository.namespace
        name      = module.git_repository.name
      }

      git = {
        checkout = {
          ref = {
            branch = module.git_repository.branch
          }
        }

        commit = {
          author = {
            name  = "flux"
            email = "flux@leightha.us"
          }

          messageTemplate = chomp(<<-EOT
            Update container images

            {{ range .Changed.Changes -}}
            - {{ .OldValue }} -> {{ .NewValue }}
            {{ end -}}
          EOT
          )
        }

        push = {
          branch = module.git_repository.branch
        }
      }

      update = {
        strategy = "Setters"
        path     = "./lib/flux/apps/${local.stack}"
      }
    }
  })
}
