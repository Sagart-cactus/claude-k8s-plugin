# k8s — Claude Code Plugin

A Claude Code plugin for building Kubernetes CRD operators with webhooks and a fast Tilt-based dev loop.

This plugin guides you through the entire operator lifecycle: requirements gathering, scaffolding with Kubebuilder, implementing controllers and webhooks, setting up a fast dev loop with Tilt, and validating your deployment — all within Claude Code.

## Installation

```bash
# Add the marketplace
claude plugin marketplace add https://github.com/Sagart-cactus/claude-k8s-plugin

# Install the plugin
claude plugin install k8s@sagart-devtools
```

## What You Get

### Commands

| Command | Description |
|---------|-------------|
| `/k8s:create-operator` | Guided workflow to create a complete K8s operator |
| `/k8s:prereqs` | Check and install prerequisites |
| `/k8s:create-cluster` | Create a kind cluster |
| `/k8s:deploy` | Deploy Kustomize dev overlay to kind |
| `/k8s:verify` | Verify CRDs, pods, webhooks, and events |
| `/k8s:dev` | Start the Tilt dev loop |
| `/k8s:checklist` | Run quality and safety checklist |

### Skills

| Skill | Description |
|-------|-------------|
| `k8s-workflow` | Agent contract and fast dev loop workflow |
| `k8s-crd-design` | CRD schema, webhook, RBAC, and reconcile patterns |
| `k8s-templates` | Tiltfile, Makefile, and Kustomize starter templates |
| `k8s-quality-checklist` | Safety, CRD, webhook, RBAC, and dev loop checklists |

### Safety Hooks

- **Context guard** (PreToolUse): Blocks kubectl/helm/kustomize commands when the current context is not a `kind-*` cluster.
- **Post-edit guidance** (PostToolUse): Suggests next steps after editing K8s-related files (types, controllers, webhooks, config).

## Quick Start

```
# 1. Check prerequisites
/k8s:prereqs

# 2. Create a kind cluster
/k8s:create-cluster

# 3. Start the guided operator creation
/k8s:create-operator

# 4. (After scaffolding) Start the dev loop
/k8s:dev

# 5. Verify everything is working
/k8s:verify

# 6. Run the quality checklist
/k8s:checklist
```

## Prerequisites

The following tools are required (installed automatically via `/k8s:prereqs`):

- [Go](https://go.dev/) — Language for the operator
- [Kubebuilder](https://kubebuilder.io/) — Scaffolding and code generation
- [kind](https://kind.sigs.k8s.io/) — Local Kubernetes clusters
- [kubectl](https://kubernetes.io/docs/tasks/tools/) — Kubernetes CLI
- [Kustomize](https://kustomize.io/) — Manifest management
- [Tilt](https://tilt.dev/) — Fast dev loop with live updates

## Safety

This plugin enforces dev-only safety by default:

- **Kind-only contexts**: The context guard hook blocks kubectl/helm/kustomize commands unless the current context is `kind-*`. This prevents accidental operations on production clusters.
- **Explicit overrides**: The guard can be bypassed only if you explicitly switch to a non-kind context and acknowledge the risk.
- **Non-destructive defaults**: The guided workflow avoids destructive operations and uses safe failure policies in dev.

## License

MIT
