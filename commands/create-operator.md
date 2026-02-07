---
description: Guided workflow to create a complete Kubernetes CRD operator.
---
# Create Kubernetes Operator

You are guiding the user through creating a Kubernetes CRD operator with webhooks and a fast Tilt-based dev loop. Follow these steps in order.

## Step 1: Requirements Gathering

Ask these 10 questions and wait for answers before writing any code:

1. **CRD purpose**: What does this operator manage? (1 sentence)
2. **Spec fields**: What fields go in the spec? (name, type, required?)
3. **Status fields**: What should be reported in status?
4. **Webhook type**: Validating, mutating, or both?
5. **Defaulting rules**: Any fields that should be auto-defaulted?
6. **Validation rules**: What invariants must be enforced?
7. **RBAC scope**: Namespace-scoped or cluster-scoped?
8. **Resource ownership**: What child resources does the controller create/manage?
9. **Failure policy**: For webhooks — Fail or Ignore?
10. **Safety gates**: Any annotations/labels required to enable mutations?

## Step 2: Scaffold the Project

Once requirements are confirmed:

1. Initialize a Kubebuilder project:
   ```
   kubebuilder init --domain <domain> --repo <module>
   kubebuilder create api --group <group> --version v1 --kind <Kind>
   kubebuilder create webhook --group <group> --version v1 --kind <Kind> --defaulting --programmatic-validation
   ```

2. Implement the CRD types in `api/v1/<kind>_types.go` based on the spec/status fields.

3. Run `make generate && make manifests` to regenerate deepcopy and CRD manifests.

## Step 3: Implement Controller Logic

Write the reconcile loop in `internal/controller/<kind>_controller.go`:
- Fetch the CR
- Check if deleted (handle finalizers)
- Create/update owned resources
- Update status
- Requeue as needed

Follow idempotency: the reconcile function should be safe to call multiple times.

## Step 4: Implement Webhooks

In `api/v1/<kind>_webhook.go`:
- **Defaulting**: Set default values for optional fields
- **Validation**: Enforce invariants on create and update
- Keep webhook logic simple and fast

## Step 5: Set Up Dev Loop

1. Create the Kustomize dev overlay (`config/dev/`) — refer to the `k8s-templates` skill.
2. Create a `Tiltfile` — refer to the `k8s-templates` skill.
3. Add `make dev` target to the Makefile.

## Step 6: Deploy and Validate

1. Ensure kind cluster exists: `/k8s-operator:create-cluster`
2. Deploy: `/k8s-operator:deploy`
3. Verify: `/k8s-operator:verify`
4. Create a sample CR and verify the controller reconciles it
5. Test webhook by submitting an invalid CR (should be rejected)

## Step 7: Quality Check

Run `/k8s-operator:checklist` to verify all safety, CRD, webhook, RBAC, and dev loop items pass.

## Output Expectations

By the end of this workflow, the project should have:
- Working CRD with structural schema
- Controller that reconciles CRs and manages child resources
- Webhooks for validation and/or defaulting
- Kustomize dev overlay + Tiltfile for fast iteration
- Minimal RBAC rules
- A short runbook in README.md: `make dev`, example CRs, how to see logs
