---
name: k8s-crd-design
description: CRD schema, webhook, RBAC, and reconcile loop patterns
---

# Kubernetes CRD Design Patterns

Use these patterns when designing and implementing CRDs, webhooks, controllers, and RBAC for Kubernetes operators.

## 1. Problem Framing

Before writing code, answer:
- Summarize the user problem in one sentence.
- List the CRD's top 3 responsibilities.
- Identify safety risks (what could go wrong if the controller misbehaves?).

## 2. CRD Schema Design

Propose a CRD with:
- **Spec fields**: Required fields with types and validation markers. Use kubebuilder markers (`+kubebuilder:validation:*`).
- **Status fields**: Observed state, conditions, and last-reconciled generation.
- **Defaults**: Use `+kubebuilder:default:=` markers for sensible defaults.
- **Validation**: Use `+kubebuilder:validation:Enum`, `+kubebuilder:validation:Minimum`, `+kubebuilder:validation:Pattern` as appropriate.
- **Printer columns**: Add `+kubebuilder:printcolumn` for useful `kubectl get` output.

Example pattern:
```go
// +kubebuilder:object:root=true
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="Ready",type=string,JSONPath=`.status.conditions[?(@.type=="Ready")].status`
// +kubebuilder:printcolumn:name="Age",type=date,JSONPath=`.metadata.creationTimestamp`
type MyResource struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`
    Spec              MyResourceSpec   `json:"spec,omitempty"`
    Status            MyResourceStatus `json:"status,omitempty"`
}
```

## 3. Webhook Design

### Validating Webhook
- Block invalid creates and updates.
- Enforce immutable fields on update.
- Validate cross-field constraints.
- Return clear error messages.

### Mutating Webhook
- Only default safe, optional fields.
- Never mutate fields the user explicitly set.
- Add labels/annotations the controller needs.
- Keep mutations minimal and predictable.

### Failure Policy
- **Dev**: `Ignore` (don't block the cluster if webhook is down)
- **Production**: `Fail` (safety over availability)

## 4. Reconcile Loop Outline

Standard reconcile pattern:
1. Fetch the CR by name. If not found, return (deleted).
2. Check for deletion timestamp — handle finalizers.
3. Compute desired state from spec.
4. For each owned resource:
   - Get current state
   - Compare with desired state
   - Create, update, or delete as needed
5. Update CR status with observed state and conditions.
6. Requeue if needed (e.g., waiting for external resource).

Key principles:
- **Idempotent**: Safe to call multiple times with the same input.
- **Level-triggered**: React to current state, not events.
- **Owner references**: Set on all created resources for garbage collection.
- **Status conditions**: Use standard condition types (Ready, Progressing, Degraded).

## 5. RBAC Minimization

List the minimal permissions the controller needs:
- **Own CRD**: get, list, watch, update (status subresource), patch
- **Owned resources**: get, list, watch, create, update, patch, delete
- **Events**: create, patch (for recording events)
- **Webhook**: no extra RBAC (handled by API server)

Avoid:
- Cluster-wide permissions unless the CRD is cluster-scoped
- Wildcard resources or verbs
- Permissions on resources the controller doesn't manage

## 6. Test Outline

Minimum test coverage:
- **Unit tests**: Reconcile logic with mock client (table-driven)
- **Envtest tests**: Full API server + etcd for webhook validation
- **Example manifests**: Valid and invalid CRs for manual testing

```go
// Example envtest setup
var _ = BeforeSuite(func() {
    testEnv = &envtest.Environment{
        CRDDirectoryPaths: []string{filepath.Join("..", "config", "crd", "bases")},
        WebhookInstallOptions: envtest.WebhookInstallOptions{
            Paths: []string{filepath.Join("..", "config", "webhook")},
        },
    }
    // ...
})
```
