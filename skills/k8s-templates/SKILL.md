---
name: k8s-templates
description: Tiltfile, Makefile, and Kustomize templates for K8s operators
---

# Kubernetes Operator Templates

Starter templates for the dev loop. Adapt paths and names to your project.

## Makefile

```make
.PHONY: dev kind deploy verify prereqs generate manifests

# Start Tilt dev loop
dev:
	tilt up

# Create kind cluster
kind:
	./scripts/setup-kind.sh

# Deploy dev overlay
deploy:
	./scripts/deploy-dev.sh

# Verify deployment
verify:
	./scripts/verify-dev.sh

# Check prerequisites
prereqs:
	./scripts/prereqs.sh

# Generate deepcopy
generate:
	go generate ./...

# Generate CRD manifests
manifests:
	controller-gen rbac:roleName=manager-role crd webhook paths="./..." output:crd:artifacts:config=config/crd/bases
```

## Kustomize Dev Overlay

### `config/dev/kustomization.yaml`

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../default

patchesStrategicMerge:
  - manager_dev_patch.yaml
```

### `config/dev/manager_dev_patch.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: controller-manager
  namespace: system
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: manager
          image: local/dev-manager:dev
          args:
            - --leader-elect=false
```

Key dev overlay settings:
- Single replica (no leader election)
- Local dev image tag (Tilt will live-update)
- Reduced resource limits if needed
- Local webhook certs (if required)

## Tiltfile

```python
# Safety: only allow kind clusters
allow_k8s_contexts('kind-kind')

# Apply kustomize manifests
k8s_yaml(kustomize('config/dev'))

# Local compile step
local_resource(
    'build-manager',
    'go build -o bin/manager ./cmd',
    deps=['cmd', 'api', 'internal', 'pkg'],
)

# Image with live update to sync binary
docker_build(
    'local/dev-manager',
    '.',
    only=['bin/manager'],
    live_update=[
        sync('bin/manager', '/manager'),
        run('pkill -f /manager || true'),
    ],
)

# Associate image with k8s resource
k8s_resource('controller-manager', image='local/dev-manager', deps=['build-manager'])
```

### Tiltfile Notes

- `allow_k8s_contexts` enforces the kind-only safety guardrail.
- Adjust `'./cmd'` to match your project's main package path.
- If the container runs `/manager` as PID 1, `pkill` causes a restart.
- For containers with a supervisor, adjust the restart mechanism.
- Add `deps` arrays to match your project structure.

## Dockerfile (minimal, for dev)

```dockerfile
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY bin/manager /manager
USER 65532:65532
ENTRYPOINT ["/manager"]
```

This Dockerfile is only used for the initial image build. After that, Tilt live-updates the binary directly.
