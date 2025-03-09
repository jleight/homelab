---
repository: homelab
---

# Homelab

My homelab config.

## Dependencies

This homelab configuration depends on the following tools:

- [mise-en-place](https://mise.jdx.dev/)
- [arp-scan](https://github.com/royhills/arp-scan)

Other dependencies can be automatically installed by running `mise install`.

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

## References

### BGP

- https://rajsingh.info/p/cilium-unifi/
- https://gerardsamuel.me/posts/homelab/howto-setup-kubernetes-cilium-bgp-with-unifi-v4.1-router/
- https://github.com/cilium/cilium/discussions/36804

### Gateway API

- https://github.com/xtineskim/gatewayapi-demo
