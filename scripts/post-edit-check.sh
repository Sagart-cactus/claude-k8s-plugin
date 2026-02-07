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

# Check if the edited file matches k8s patterns
case "$FILE_PATH" in
  */config/*)
    echo "Kustomize/config change detected. Consider running:"
    echo "  /k8s-operator:deploy   - Apply changes to kind cluster"
    echo "  /k8s-operator:verify   - Check CRDs, pods, and webhooks"
    ;;
  *_types.go)
    echo "CRD types changed. Consider running:"
    echo "  make generate && make manifests  - Regenerate CRD manifests"
    echo "  /k8s-operator:deploy             - Apply to kind cluster"
    echo "  /k8s-operator:verify             - Verify CRDs are updated"
    ;;
  *_webhook.go)
    echo "Webhook code changed. Consider running:"
    echo "  /k8s-operator:deploy   - Redeploy to kind cluster"
    echo "  /k8s-operator:verify   - Check webhook configurations"
    ;;
  *_controller.go|*_reconciler.go)
    echo "Controller code changed. Consider running:"
    echo "  /k8s-operator:dev      - Start/restart Tilt dev loop"
    echo "  /k8s-operator:verify   - Check pod status and events"
    ;;
  *Tiltfile*|*Makefile*)
    echo "Build config changed. Consider running:"
    echo "  /k8s-operator:dev      - Restart Tilt dev loop"
    ;;
  *)
    # Not a k8s-related file, no suggestion
    ;;
esac

exit 0
