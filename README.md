# homelab
## Overview

This is a monorepo for the cluster that lives on my desk, which I called
`Atlas`. It uses [Flux](https://fluxcd.io) to deploy services from this
repository into my cluster.

It automatically updates itself over time using
[Renovate](https://docs.renovatebot.com/), and tests pull requests for those
updates using [GitHub Actions](https://github.com/features/actions).

---

## Kubernetes

Atlas is a 3 nodes Kubernetes cluster deployed with [Talos](https://www.talos.dev) on top of Proxmox.

### Core Components
- [fluxcd](https://fluxcd.io/flux/get-started/): Minimalistic GitOps Operator.
- [cert-manager](https://github.com/cert-manager/cert-manager): Manages TLS certificates via Let's Encrypt.
- [cilium](https://github.com/cilium/cilium): eBPF-based networking and L2 load balancing with VIPs.
- [Traefik](https://doc.traefik.io/traefik/): ingress controller for the Traefik proxy.
- [longhorn](https://github.com/longhorn/longhorn): Clustered storage system that handles all the difficult things for me, and is very easy to deploy.

---
