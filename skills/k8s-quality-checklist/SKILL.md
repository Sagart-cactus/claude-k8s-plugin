---
name: k8s-quality-checklist
description: Safety, CRD, webhook, RBAC, and dev loop checklists
---

# Kubernetes Operator Quality Checklist

Use this checklist to evaluate operator quality before considering it production-ready or before each iteration.

## Safety (dev-only)

- Target cluster is kind or an explicitly allowed dev cluster
- Leader election disabled for dev overlay
- Single replica manager in dev
- Webhook timeouts are short for dev (e.g., 10s)
- Webhook only mutates resources it owns or is explicitly allowed to modify
- No destructive operations without explicit user confirmation

## CRD Quality

- Structural schema is valid and complete
- Required fields are properly marked
- Default values are defined for optional fields where sensible
- Status subresource is enabled when status is used
- Printer columns defined for useful `kubectl get` output
- CRD categories are set for discoverability
- Validation markers enforce all invariants from requirements

## Webhook Quality

- Validating webhook covers all invariants
- Mutating webhook only defaults safe, optional fields
- Immutable fields are enforced on update
- Cross-field validation is implemented
- Clear error messages are returned on rejection
- Failure policy is appropriate for the environment
- Certificates exist and are correctly mounted
- Webhook service endpoints resolve

## RBAC Quality

- Minimal verbs: only what the controller actually needs
- Minimal resources: no wildcards unless justified
- No unnecessary cluster-wide permissions
- Separate roles for manager and webhook if they have different needs
- ServiceAccount is dedicated (not `default`)

## Controller Quality

- Reconcile loop is idempotent
- Owner references set on all created resources
- Finalizers used for cleanup of external resources
- Status conditions follow standard types (Ready, Progressing, Degraded)
- Events recorded for significant state changes
- Requeue with backoff for transient errors
- No long-running operations in reconcile (use async patterns)

## Fast Loop Quality

- `make dev` / `tilt up` starts without errors
- Local compile succeeds
- Binary sync into running pod works reliably
- Process restart is reliable after sync
- Logs show new version after code edit
- CRD changes are applied through Kustomize automatically
- Webhook changes take effect without manual restart

## Test Quality

- Unit tests for core reconcile logic (table-driven)
- Envtest or integration tests for webhook validation
- Example CR manifests for manual testing (valid and invalid)
- Tests cover error paths and edge cases

## Troubleshooting Guide

When things go wrong:

1. **Tilt sync errors**: Check Tilt UI or logs for build/sync failures
2. **Pod crash loops**: `kubectl logs -n <ns> <pod> --previous`
3. **Webhook failures**: Check webhook service endpoints and certificate secrets
4. **CRD not applied**: `kubectl get crd <name> -o yaml` and check for schema errors
5. **RBAC errors**: `kubectl auth can-i --as system:serviceaccount:<ns>:<sa> <verb> <resource>`
6. **Reconcile not triggering**: Check controller logs for watch errors, verify RBAC
