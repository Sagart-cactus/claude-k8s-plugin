# Changelog

## v0.1.1

### Changed
- Renamed plugin command namespace from `k8s-operator` to `k8s`
- Updated install command reference to `claude plugin install k8s@sagart-devtools`
- Renamed workflow skill identifier from `k8s-operator-workflow` to `k8s-workflow`

## v0.1.0

Initial release.

### Commands
- `create-operator`: Guided workflow for creating a complete K8s CRD operator
- `prereqs`: Auto-detect OS and install missing tools
- `create-cluster`: Create an idempotent kind cluster
- `deploy`: Deploy Kustomize dev overlay to kind
- `verify`: Check CRDs, pods, webhooks, and events
- `dev`: Start Tilt dev loop
- `checklist`: Quality and safety evaluation checklist

### Skills
- `k8s-workflow`: Agent contract, Q&A requirements, dev loop workflow
- `k8s-crd-design`: CRD schema, webhook, RBAC, and reconcile loop patterns
- `k8s-templates`: Tiltfile, Makefile, and Kustomize dev overlay templates
- `k8s-quality-checklist`: Safety, CRD, webhook, RBAC, and dev loop checklists

### Hooks
- PreToolUse context guard: blocks kubectl/helm/kustomize on non-kind contexts
- PostToolUse edit guidance: suggests next steps after editing K8s files

### Scripts
- `prereqs.sh`: Auto-detect OS, install missing tools (no interactive prompts)
- `setup-kind.sh`: Idempotent kind cluster creation
- `deploy-dev.sh`: Kustomize build + apply with context guard
- `verify-dev.sh`: Show CRDs, pods, webhooks, events
- `context-guard.sh`: PreToolUse hook for kind-only safety
- `post-edit-check.sh`: PostToolUse hook for edit guidance
