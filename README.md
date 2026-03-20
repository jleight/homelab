---
repository: homelab
---

# Homelab

My homelab config.

## Dependencies

This homelab configuration uses [mise-en-place](https://mise.jdx.dev/) to install its dependencies.

## Bootstrapping the Cluster

The terraform modules aren't split up properly, yet, so they need to be applied in a specific order:

1. Apply the cluster module:
   1. Disable the `talos_machine_bootstrap` resource.
   2. Apply the module.
   3. Apply the module again to pick up the new node IPs.
   4. Enable the `talos_machine_bootstrap` resource.
   5. Apply the module again to bootstrap the nodes.
2. Apply the baseline module:
   1. Disable any optional services in `environment.hcl`.
   2. Apply the module.
   3. Enable storage services in `environment.hcl`.
   4. Apply the module again.
   5. Enable the rest of the services.
   6. Apply the module again.

## Upgrading the Cluster

First, upgrade talos.
You should upgrade to the latest patch version before upgrading to the next minor version.

1. Modify the version in the `k8s/cluster/variables.tf` file.
2. Apply the module.
3. Run the `talosctl upgrade` commands (one for each node) that the module outputs.

Then, upgrade kubernetes.
Again, upgrade to the latest patch version before upgrading to the next minor version.

1. Run `talosctl --nodes ${node_ip} upgrade-k8s --to ${k8s_version}` to upgrade the whole cluster.
2. Modify the `k8s_version` in `global.hcl`.
3. Apply the cluster module.

## References

### BGP

- https://rajsingh.info/p/cilium-unifi/
- https://gerardsamuel.me/posts/homelab/howto-setup-kubernetes-cilium-bgp-with-unifi-v4.1-router/
- https://github.com/cilium/cilium/discussions/36804

### Gateway API

- https://github.com/xtineskim/gatewayapi-demo
