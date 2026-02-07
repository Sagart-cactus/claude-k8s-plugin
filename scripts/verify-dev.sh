#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-system}"

# Verify we're targeting a kind cluster
CONTEXT="$(kubectl config current-context 2>/dev/null || true)"
if [[ ! "$CONTEXT" =~ ^kind- ]]; then
  echo "ERROR: Current context '$CONTEXT' is not a kind cluster." >&2
  echo "Switch to a kind context first: kubectl config use-context kind-<name>" >&2
  exit 1
fi

echo "=== CRDs ==="
kubectl get crds 2>/dev/null || echo "(none)"

echo ""
echo "=== Pods in namespace '${NAMESPACE}' ==="
kubectl -n "${NAMESPACE}" get pods 2>/dev/null || echo "(none)"

echo ""
echo "=== Validating Webhook Configurations ==="
kubectl get validatingwebhookconfigurations 2>/dev/null || echo "(none)"

echo ""
echo "=== Mutating Webhook Configurations ==="
kubectl get mutatingwebhookconfigurations 2>/dev/null || echo "(none)"

echo ""
echo "=== Recent Events in namespace '${NAMESPACE}' ==="
kubectl -n "${NAMESPACE}" get events --sort-by=.lastTimestamp 2>/dev/null | tail -n 20 || echo "(none)"
