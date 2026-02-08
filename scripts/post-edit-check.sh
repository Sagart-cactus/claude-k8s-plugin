#!/usr/bin/env bash
set -euo pipefail

# PostToolUse hook: suggest next steps after editing k8s-related files.
# Reads tool input JSON from stdin.

INPUT="$(cat)"

# Extract the file path from tool input
FILE_PATH=""
if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null || true)"
else
  FILE_PATH="$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)"
fi

[ -z "$FILE_PATH" ] && exit 0

# Check if the edited file matches k8s patterns and output JSON for visibility
# (plain stdout is hidden for PostToolUse hooks; additionalContext is surfaced to Claude)
MSG=""
case "$FILE_PATH" in
  */config/*)
    MSG="Kustomize/config change detected. Run: /k8s:deploy (apply to kind) then /k8s:verify (check CRDs, pods, webhooks)"
    ;;
  *_types.go)
    MSG="CRD types changed. Run: make generate && make manifests, then /k8s:deploy and /k8s:verify"
    ;;
  *_webhook.go)
    MSG="Webhook code changed. Run: /k8s:deploy (redeploy) then /k8s:verify (check webhook configs)"
    ;;
  *_controller.go|*_reconciler.go)
    MSG="Controller code changed. Run: /k8s:dev (start/restart Tilt) then /k8s:verify (check pods and events)"
    ;;
  *Tiltfile*|*Makefile*)
    MSG="Build config changed. Run: /k8s:dev (restart Tilt dev loop)"
    ;;
esac

if [ -n "$MSG" ]; then
  printf '{"additionalContext": "%s"}\n' "$MSG"
fi

exit 0
