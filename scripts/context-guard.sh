#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook: block kubectl/helm/kustomize commands targeting non-kind clusters.
# Reads tool input JSON from stdin.
# Exit 0 = allow, Exit 2 = block with message.

INPUT="$(cat)"

# Extract the command string from the tool input.
# Try jq first, fall back to grep-based parsing.
COMMAND=""
if command -v jq >/dev/null 2>&1; then
  COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
else
  COMMAND="$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)"
fi

# Fast exit: if the command doesn't involve kubectl, helm, or kustomize, allow it
if [[ -z "$COMMAND" ]] || ! echo "$COMMAND" | grep -qE '\b(kubectl|helm|kustomize)\b'; then
  exit 0
fi

# Check if applying/deploying (read-only commands are allowed regardless)
# Allow: get, describe, logs, explain, api-resources, api-versions, version, config view, config get-contexts
if echo "$COMMAND" | grep -qE '\bkubectl\b' && echo "$COMMAND" | grep -qE '\b(get|describe|logs|explain|api-resources|api-versions|version)\b' && ! echo "$COMMAND" | grep -qE '\b(apply|create|delete|patch|replace|edit|scale|rollout|drain|cordon|uncordon|taint|label|annotate)\b'; then
  exit 0
fi

# Check current context
CONTEXT="$(kubectl config current-context 2>/dev/null || true)"
if [[ "$CONTEXT" =~ ^kind- ]]; then
  exit 0
fi

# Block: not a kind context
echo "BLOCKED: kubectl/helm/kustomize command detected but current context '${CONTEXT}' is not a kind cluster."
echo "Safety guardrail: this plugin only allows operations on kind-* contexts."
echo "To switch: kubectl config use-context kind-<cluster-name>"
exit 2
