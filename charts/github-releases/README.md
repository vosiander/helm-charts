# GitHub Releases MCP Server Helm Chart

This Helm chart deploys the GitHub Releases MCP (Model Context Protocol) server on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- GitHub Personal Access Token (for API access)

## Installing the Chart

### Quick Start

```bash
# Install with direct token (development/testing)
helm install github-releases ./helm \
  --set github.token=ghp_your_token_here

# Install with existing secret (production - recommended)
kubectl create secret generic github-token \
  --from-literal=token=ghp_your_token_here

helm install github-releases ./helm \
  --set github.existingSecret=github-token
```

### Using a values file

Create a `my-values.yaml` file:

```yaml
image:
  repository: ghcr.io/vosiander/github-releases
  tag: "v1.0.0"  # Use specific version

github:
  existingSecret: "github-token"
  secretKey: "token"

service:
  type: ClusterIP
  port: 8556

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

Install with:

```bash
helm install github-releases ./helm -f my-values.yaml
```

## Configuration

The following table lists the configurable parameters of the chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/vosiander/github-releases` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag (overrides chart appVersion) | `""` |
| `github.token` | GitHub token (for dev/test only) | `""` |
| `github.existingSecret` | Name of existing secret with GitHub token | `""` |
| `github.secretKey` | Key in secret containing the token | `"token"` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | MCP server port | `8556` |
| `resources` | CPU/Memory resource requests/limits | `{}` |

## GitHub Token Configuration

### Option 1: Direct Token (Development/Testing)

⚠️ **Not recommended for production**

```bash
helm install github-releases ./helm \
  --set github.token=ghp_your_token_here
```

### Option 2: Existing Secret (Production - Recommended)

Create a secret first:

```bash
kubectl create secret generic github-token \
  --from-literal=token=ghp_your_token_here
```

Then install the chart:

```bash
helm install github-releases ./helm \
  --set github.existingSecret=github-token
```

Or in your values file:

```yaml
github:
  existingSecret: "github-token"
  secretKey: "token"
```

## Accessing the MCP Server

The MCP server runs on port 8556 by default. To access it:

### Port Forward

```bash
kubectl port-forward svc/github-releases 8556:8556
```

Then connect to `http://localhost:8556`

### Through Ingress

Enable ingress in your values:

```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: github-releases.example.com
      paths:
        - path: /
          pathType: Prefix
```

## Upgrading

```bash
helm upgrade github-releases ./helm -f my-values.yaml
```

## Uninstalling

```bash
helm uninstall github-releases
```

## Health Checks

The MCP server does not expose HTTP health endpoints. The chart disables HTTP probes by default. You can enable TCP probes if needed:

```yaml
livenessProbe:
  tcpSocket:
    port: mcp
  initialDelaySeconds: 15
  periodSeconds: 20

readinessProbe:
  tcpSocket:
    port: mcp
  initialDelaySeconds: 5
  periodSeconds: 10
```

## Examples

### Minimal Installation

```bash
helm install github-releases ./helm \
  --set github.token=ghp_token
```

### Production Installation

```bash
# Create namespace
kubectl create namespace github-releases

# Create secret
kubectl create secret generic github-token \
  --from-literal=token=ghp_your_production_token \
  -n github-releases

# Install with resource limits
helm install github-releases ./helm \
  --namespace github-releases \
  --set github.existingSecret=github-token \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=128Mi \
  --set resources.limits.cpu=200m \
  --set resources.limits.memory=256Mi
```

### With Ingress

```bash
helm install github-releases ./helm \
  --set github.existingSecret=github-token \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=github-releases.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=helm
```

### View Logs

```bash
kubectl logs -l app.kubernetes.io/name=helm
```

### Check Configuration

```bash
kubectl describe pod -l app.kubernetes.io/name=helm
```

### Test GitHub Token

```bash
kubectl exec -it deployment/github-releases -- \
  sh -c 'echo $GITHUB_TOKEN'
