---
description: Run the quality and safety checklist for a Kubernetes operator.
---
# Kubernetes Operator Quality Checklist

Evaluate the current project against each item below. For each item, report PASS, FAIL, or N/A with a brief explanation.

## Safety (dev-only)

- [ ] Target cluster is kind or explicitly allowed dev cluster
- [ ] Leader election disabled for dev overlay
- [ ] Single replica manager in dev
- [ ] Webhook timeouts are short for dev (e.g., 10s)
- [ ] Webhook only mutates resources it owns or is explicitly allowed to modify

## CRD

- [ ] Structural schema is valid (`kubectl get crd <name> -o yaml` shows no errors)
- [ ] Required fields are marked in the schema
- [ ] Default values are defined where possible
- [ ] Status subresource is enabled (if status is used)
- [ ] Printer columns are defined for useful `kubectl get` output

## Webhooks

- [ ] Validating webhook covers all invariants from requirements
- [ ] Mutating webhook only defaults safe fields
- [ ] Failure policy is appropriate (Fail for prod safety, Ignore for dev flexibility)
- [ ] Certificates exist and are mounted correctly
- [ ] Webhook service endpoints resolve

## RBAC

- [ ] Minimal verbs (only what the controller needs)
- [ ] Minimal resources (no wildcards unless justified)
- [ ] No unnecessary cluster-wide permissions
- [ ] Separate roles for manager and webhook if needed

## Fast Loop

- [ ] `make dev` / `tilt up` starts without errors
- [ ] Local compile succeeds
- [ ] Binary sync into running pod works
- [ ] Process restart is reliable after sync
- [ ] Logs show new version after code edit
- [ ] CRD changes are applied through Kustomize

## Tests

- [ ] Unit tests exist for core reconcile logic
- [ ] Envtest or integration tests exist for webhook validation
- [ ] Example CR manifests exist for manual testing

## Troubleshooting (verify if any failures above)

- [ ] Check Tilt logs for sync errors
- [ ] Check pod logs for crash loops (`kubectl logs -n <ns> <pod>`)
- [ ] Verify webhook service endpoints (`kubectl get endpoints -n <ns>`)
- [ ] Check certificate secrets exist
- [ ] Verify RBAC with `kubectl auth can-i --as system:serviceaccount:<ns>:<sa>`

Summarize results: total PASS / FAIL / N/A and list any action items.
