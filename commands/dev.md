---
description: Start the Tilt dev loop for fast operator iteration.
---
Run `tilt up` in the project root.

This starts the Tilt fast dev loop which:
1. Builds the manager binary locally with `go build`
2. Applies Kustomize manifests (CRDs, RBAC, webhooks, deployment)
3. Syncs the binary into the running manager pod
4. Restarts the manager process on code changes

Prerequisites:
- A kind cluster must be running (`/k8s:create-cluster`)
- A `Tiltfile` must exist in the project root (use the `k8s-templates` skill for a starter)
- The Kustomize dev overlay must be configured (`config/dev/`)

To stop Tilt, press Ctrl+C in the terminal.
