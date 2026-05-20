resource "random_password" "vernemq_internal" {
  count = local.enabled ? 1 : 0

  length  = 32
  special = false
}

# TLS cert for the publicly-exposed MQTTS listener. The public LB gateway runs
# the matching listener in passthrough mode, so VerneMQ terminates TLS itself
# using this secret.
resource "kubectl_manifest" "vernemq_certificate" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      namespace = local.namespace
      name      = local.vernemq_name

      labels = local.labels
    }

    spec = {
      secretName = local.vernemq_cert_secret
      dnsNames   = [local.vernemq_public_host]
      issuerRef = {
        kind = "ClusterIssuer"
        name = "lets-encrypt"
      }
    }
  })
}

resource "helm_release" "vernemq" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.vernemq_name
  repository = var.core_scope.vernemq.repository
  chart      = var.core_scope.vernemq.chart
  version    = var.core_scope.vernemq.version

  values = [
    yamlencode({
      fullnameOverride = local.vernemq_name

      replicaCount = 1

      service = {
        type = "ClusterIP"
        mqtt = {
          enabled = true
        }
        mqtts = {
          enabled = true
          port    = 8883
        }
      }

      # Mount the cert-manager-issued cert into the pod so the SSL listener
      # can pick it up via the LISTENER__SSL__CERTFILE / KEYFILE env vars.
      secretMounts = [
        {
          name       = "vernemq-tls"
          secretName = local.vernemq_cert_secret
          path       = "/etc/ssl/vernemq"
        }
      ]

      # No durable session state needed — CoreScope subscribes immediately
      # and external publishers use QoS 0. Skipping the PVC also avoids the
      # extra storage class plumbing.
      persistentVolume = {
        enabled = false
      }

      additionalEnv = [
        for k, v in {
          "DOCKER_VERNEMQ_ACCEPT_EULA" = "yes"

          "DOCKER_VERNEMQ_ALLOW_REGISTER_DURING_NETSPLIT"    = "on"
          "DOCKER_VERNEMQ_ALLOW_PUBLISH_DURING_NETSPLIT"     = "on"
          "DOCKER_VERNEMQ_ALLOW_SUBSCRIBE_DURING_NETSPLIT"   = "on"
          "DOCKER_VERNEMQ_ALLOW_UNSUBSCRIBE_DURING_NETSPLIT" = "on"

          "DOCKER_VERNEMQ_ALLOW_ANONYMOUS" = "off"

          "DOCKER_VERNEMQ_LISTENER__SSL__DEFAULT"  = "0.0.0.0:8883"
          "DOCKER_VERNEMQ_LISTENER__SSL__CERTFILE" = "/etc/ssl/vernemq/tls.crt"
          "DOCKER_VERNEMQ_LISTENER__SSL__KEYFILE"  = "/etc/ssl/vernemq/tls.key"
          "DOCKER_VERNEMQ_LISTENER__SSL__CAFILE"   = "/etc/ssl/vernemq/tls.crt"

          "DOCKER_VERNEMQ_PLUGINS__VMQ_WEBHOOKS" = "on"

          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_REGISTER__HOOK"     = "auth_on_register"
          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_REGISTER__ENDPOINT" = "http://${local.vernemq_auth_name}:${local.vernemq_auth_port}/auth/register"

          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_PUBLISH__HOOK"     = "auth_on_publish"
          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_PUBLISH__ENDPOINT" = "http://${local.vernemq_auth_name}:${local.vernemq_auth_port}/auth/publish"

          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_SUBSCRIBE__HOOK"     = "auth_on_subscribe"
          "DOCKER_VERNEMQ_VMQ_WEBHOOKS__USER_SUBSCRIBE__ENDPOINT" = "http://${local.vernemq_auth_name}:${local.vernemq_auth_port}/auth/subscribe"
        } : { name = k, value = v }
      ]
    })
  ]

  depends_on = [
    kubernetes_service_v1.vernemq_auth,
    kubectl_manifest.vernemq_certificate
  ]
}

# Route the public LB gateway's mqtts listener to VerneMQ. The gateway runs
# this in TLS passthrough mode, so the encrypted stream is forwarded as-is.
resource "kubectl_manifest" "vernemq_tls_route" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1alpha2"
    kind       = "TLSRoute"

    metadata = {
      namespace = local.namespace
      name      = local.vernemq_name
    }

    spec = {
      parentRefs = [
        {
          namespace   = var.gateway_namespace
          name        = var.mqtt_gateway_name
          sectionName = "mqtts"
        }
      ]
      hostnames = [
        local.vernemq_public_host
      ]
      rules = [
        {
          backendRefs = [
            {
              name = local.vernemq_name
              port = 8883
            }
          ]
        }
      ]
    }
  })

  depends_on = [helm_release.vernemq]
}
