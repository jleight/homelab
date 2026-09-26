variable "namespace" {
  description = "The namespace the Provider and its Alerts are created in."
  type        = string
}

variable "vault" {
  description = "The name of the 1Password vault containing Terraform secrets."
  type        = string
  default     = "Terraform"
}

variable "failure_event_sources" {
  description = "Kinds the error-severity alert watches in the namespace. Overlaps update_event_sources on purpose: the updates alert only passes success messages, so those kinds' errors are reported here."
  type        = set(string)
  default = [
    "Kustomization",
    "HelmRelease",
    "GitRepository",
    "ImageRepository",
    "ImagePolicy",
    "ImageUpdateAutomation"
  ]
}

variable "failure_exclusions" {
  description = "Golang regular expressions matched against error messages the failures alert should not report. Flux retries every error on its next interval, so these are the transient ones that clear up on their own; what gets through is what a retry won't fix (bad manifests, failed chart upgrades, rejected credentials)."
  type        = list(string)

  default = [
    # Network: DNS, dial and read timeouts, dropped or refused connections.
    "i/o timeout",
    "context deadline exceeded",
    "TLS handshake timeout",
    "connection (reset by peer|refused|timed out)",
    "server misbehaving",
    # Registry or forge having a bad moment.
    "status code 50[234]",
    # The API server rejecting a controller's token, seen while etcd was unhealthy.
    "^Unauthorized$",
    # A new ImagePolicy asked before its ImageRepository's first scan landed.
    "no tags in database",
    # GitHub occasionally refuses the homelab-push deploy key on an image
    # automation's checkout; the retry seconds later succeeds. Anchored to the
    # automation's wording so a truly revoked key still surfaces through the
    # homelab-push GitRepository ("failed to checkout and determine revision").
    "^failed to checkout source: .*ssh: handshake failed"
  ]
}

variable "update_event_sources" {
  description = "Kinds the info-severity alert watches in the namespace: a new image tag selected, or a chart installed or upgraded."
  type        = set(string)
  default     = ["ImagePolicy", "HelmRelease"]
}

variable "update_inclusions" {
  description = "Golang regular expressions an event message must match for the updates alert to report it. Info severity also passes errors and no-op re-resolves, so only real changes are let through."
  type        = list(string)

  default = [
    # ImagePolicy only names the previous image when the tag or digest actually
    # changed; a policy re-resolving to the same image after a scan failure omits it.
    "\\(previously ",
    "^Helm (install|upgrade) succeeded"
  ]
}
