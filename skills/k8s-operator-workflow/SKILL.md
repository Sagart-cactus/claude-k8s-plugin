---
name: k8s-workflow
description: Agent contract and fast dev loop for K8s operator development
---

# Kubernetes Operator Workflow

## Operating Mode

- **Dev-only**: Target kind clusters only. Refuse operations on non-kind contexts unless user explicitly overrides.
- **MCP preferred**: If a Kubernetes MCP server is available, use it for cluster validation. Otherwise, fall back to `kubectl` commands.
- **Safety first**: Allow only `kind-*` contexts. Avoid destructive operations by default.

## Agent Responsibilities

1. Ask questions to clarify CRD purpose, fields, validation rules, webhook type, and safety constraints.
2. Generate CRD schema and example custom resources.
3. Scaffold controller and webhook code using Go + Kubebuilder patterns.
4. Create dev loop config: Tiltfile + Kustomize dev overlay + Makefile target.
5. Create a kind cluster and install CRDs/webhooks.
6. Validate behavior using MCP or `kubectl` and logs.
7. Iterate until requirements are satisfied.

## Required Q&A (ask before writing code)

Always ask these 10 questions and wait for answers:

1. CRD purpose (1 sentence)
2. Spec fields (name + type + required?)
3. Status fields (what should be reported?)
4. Webhook type (validating, mutating, or both)
5. Defaulting rules (if any)
6. Validation rules (invariants)
7. RBAC scope (namespace or cluster)
8. Resource ownership (what objects are created/managed)
9. Failure policy (for webhooks)
10. Safety gates (annotations/labels to enable mutations)

## Dev Fast Loop Workflow

### Overview

- One command: `make dev` (wraps `tilt up`)
- Kustomize applies CRDs, RBAC, webhook config, and manager Deployment
- Local `go build` produces the manager binary
- Tilt live-update syncs the binary into the running manager pod
- Tilt kills the process to restart with new code

### Iteration Cycle

1. Edit Go files (types, controller, webhook)
2. Tilt recompiles locally
3. Binary syncs into the running pod
4. Process restarts
5. Check logs/events for feedback

### When You Need a Full Rebuild

- Dockerfile changes
- Base image changes
- Dependency changes that affect the image environment

## Files the Agent Should Manage

- `api/v1/*_types.go` — CRD spec and status types
- `internal/controller/*_controller.go` — Reconcile loop
- `api/v1/*_webhook.go` — Webhook handlers
- `config/crd/bases/` — Generated CRD YAML
- `config/webhook/` — Webhook configuration
- `config/rbac/` — RBAC rules
- `config/dev/` — Kustomize dev overlay
- `Tiltfile` — Tilt configuration
- `Makefile` — Build and dev targets

## Safety Guardrails

- Only allow `kind-*` kubectl contexts
- Refuse operations on production or staging contexts
- Avoid destructive operations (delete namespace, delete CRD) unless explicitly confirmed
- Use failure policy `Ignore` for dev, `Fail` for production
- Disable leader election in dev (single replica)

## MCP Validation (when available)

Use MCP to verify:
- CRDs installed and versions match
- Webhook configs present
- Manager/webhook pods healthy
- Logs show reconcile activity

If MCP is not available, use equivalent `kubectl` commands.
