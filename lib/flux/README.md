# Flux

Terraform installs the flux-operator (`lib/terraform/modules/k8s/flux`) and
nothing else. The operator's `FluxInstance` tracks the `2.x` release range, so
the Flux controllers update themselves; the root sync reconciles
`lib/flux/clusters/prod` from `main` over anonymous HTTPS.

## Layout

    clusters/prod/<stack>/<app>.yaml   one Kustomization per app — what gets
                                       reconciled, and how
    apps/<stack>/<app>/                manifests for applications Flux owns

Both trees are grouped by stack so they line up with `lib/terraform/live/prod`.

## Configuration comes from a per-app ConfigMap

Flux has `dependsOn` for ordering but no equivalent of a Terragrunt dependency
output. The substitute is `postBuild.substituteFrom`, and it resolves the
ConfigMap in the **Kustomization's own namespace** — not the namespace of the
resources being applied. So each app gets:

- a Kustomization in the app's namespace, under `clusters/prod/<stack>/`, with a
  cross-namespace `sourceRef` back to `flux-system`'s GitRepository, and
- a ConfigMap in that same namespace, created by the stack's Terraform module
  next to the namespace and secrets it already owns.

There is no cluster-wide ConfigMap. An app can only read its own values, a bad
value fails only that app's Kustomization, and each app reconciles and prunes
independently.

Keys are deliberately generic — `domain`, `data_storage_class`,
`gateway_namespace`/`gateway_name`/`gateway_section` — never `public_*` or
`private_*`. Which gateway or storage class an app gets is decided in Terraform,
where the cluster topology is already known; `k8s/ingress` publishes fully-formed
parentRefs precisely so consumers never learn which gateway backs a role. Moving
an app from the public to the private gateway is a one-line Terraform change with
no commit here at all.

Substitution is plain string replacement, so only scalars can be carried. The
multi-listener parentRef roles (`corescope`, `mqtt`, `meshtender`) do not
flatten, and their apps stay in Terraform.

A variable that is missing from the ConfigMap fails the build —
`StrictPostBuildSubstitutions` is on by default. A variable that is *present but
empty* substitutes empty and fails silently, so Terraform should not paper over
an absent upstream output with `""`.

## Terraform owns namespaces and secrets

Nothing under `lib/flux` carries a `Namespace` or a `Secret`. Both are created
by Terraform alongside the rest of the stack — see
`lib/terraform/live/prod/social` for the shape — and manifests here reference
them by name.

This is not a workaround, it is the division of labour:

- A namespace is usually shared by several workloads, so no single one of them
  should own it. Keeping it out of the Flux inventory also means `prune: true`
  can never take the namespace, and everything in it, along with a deleted app.
- Secrets come from 1Password through Terraform data sources, or are generated
  with `random_password`. Flux can read neither, and SOPS is not an option
  because this repository is public. Terraform already does this well.

The consequence is an apply order on first deploy: Terraform first, then Flux.
A Kustomization that lands before its namespace or secret exists simply fails
and retries on `retryInterval`, so getting it backwards costs time, not state.

## Before moving an app here

- **Namespace and secrets declared in Terraform first.**
- **Only scalar config, and only through the app's own ConfigMap.**
- **Hand off ownership deliberately.** For a `helm_release`, `terraform state
  rm` it and let helm-controller adopt the release in place (same name and
  namespace). For manifests built by `_registry/app_deployment`,
  kustomize-controller applies server-side and will conflict with Terraform's
  field manager — the first reconcile needs `spec.force: true`. Never let
  either side delete a PVC during the handoff.

## Version policy

Chart versions here may be semver ranges (`1.x`) so minors land without a PR.
That is deliberate for applications and deliberately *not* done for the
infrastructure charts — Cilium, Longhorn, cert-manager and external-dns stay
pinned in Terraform with Renovate PRs, where a bad minor can be held back.
