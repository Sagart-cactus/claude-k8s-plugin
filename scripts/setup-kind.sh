#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:-kind}"

if ! command -v kind >/dev/null 2>&1; then
  echo "kind is not installed. Run /k8s:prereqs first." >&2
  exit 1
fi

if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "kind cluster '${CLUSTER_NAME}' already exists."
else
  echo "Creating kind cluster '${CLUSTER_NAME}'..."
  kind create cluster --name "${CLUSTER_NAME}"
fi

kubectl config use-context "kind-${CLUSTER_NAME}" >/dev/null
echo "kubectl context set to kind-${CLUSTER_NAME}"
