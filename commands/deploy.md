---
description: Deploy Kustomize dev overlay to the kind cluster.
argument-hint: [overlay-path]
---
Run `${CLAUDE_PLUGIN_ROOT}/scripts/deploy-dev.sh ${ARGUMENTS:-config/dev}`.

This builds and applies the Kustomize overlay to the current kind cluster. It will refuse to deploy to non-kind contexts.

Example: `/k8s-operator:deploy` or `/k8s-operator:deploy config/staging`
