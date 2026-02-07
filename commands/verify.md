---
description: Verify CRDs, pods, webhooks, and events in the kind cluster.
argument-hint: [namespace]
---
Run `${CLAUDE_PLUGIN_ROOT}/scripts/verify-dev.sh ${ARGUMENTS:-system}`.

This shows the current state of your operator deployment: CRDs, pods, webhook configurations, and recent events.

Example: `/k8s-operator:verify` or `/k8s-operator:verify my-operator-system`
