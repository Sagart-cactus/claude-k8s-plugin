#!/usr/bin/env bash
set -euo pipefail

OVERLAY_PATH="${1:-config/dev}"

# Verify we're targeting a kind cluster
CONTEXT="$(kubectl config current-context 2>/dev/null || true)"
if [[ ! "$CONTEXT" =~ ^kind- ]]; then
  echo "ERROR: Current context '$CONTEXT' is not a kind cluster." >&2
  echo "Switch to a kind context first: kubectl config use-context kind-<name>" >&2
  exit 1
fi

if ! command -v kustomize >/dev/null 2>&1; then
  echo "kustomize is not installed. Run /k8s-operator:prereqs first." >&2
  exit 1
fi

echo "Deploying overlay '${OVERLAY_PATH}' to context '${CONTEXT}'..."
kustomize build "${OVERLAY_PATH}" | kubectl apply -f -
echo "Deploy complete."
