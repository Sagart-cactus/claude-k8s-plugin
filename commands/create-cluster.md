---
description: Create a kind cluster for local Kubernetes development.
argument-hint: [cluster-name]
---
Run `${CLAUDE_PLUGIN_ROOT}/scripts/setup-kind.sh ${ARGUMENTS:-kind}`.

This creates a kind cluster (default name: `kind`) if it doesn't already exist and switches kubectl context to it.

Example: `/k8s-operator:create-cluster` or `/k8s-operator:create-cluster my-cluster`
