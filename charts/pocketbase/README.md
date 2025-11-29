# PocketBase Helm Chart

This Helm chart deploys [PocketBase](https://pocketbase.io/) - an open source backend consisting of embedded database (SQLite) with realtime subscriptions, built-in auth management, convenient dashboard UI and simple REST-ish API.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `my-pocketbase`:

```bash
helm install my-pocketbase ./charts/pocketbase
```

## Uninstalling the Chart

To uninstall/delete the `my-pocketbase` deployment:

```bash
helm uninstall my-pocketbase
```

## Configuration

The following table lists the configurable parameters of the PocketBase chart and their default values.

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | PocketBase image repository | `adrianmusante/pocketbase` |
| `image.tag` | PocketBase image tag | `0.34.0` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### PocketBase Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `pocketbase.debug` | Enable debug/verbose mode | `false` |
| `pocketbase.admin.email` | Admin user email | `""` |
| `pocketbase.admin.password` | Admin user password | `""` |
| `pocketbase.admin.upsert` | Always update admin from env vars | `true` |
| `pocketbase.encryptionKey` | Encryption key for settings | `""` |
| `pocketbase.existingSecret` | Existing secret with encryption key | `""` |
| `pocketbase.extraArgs` | Additional command-line arguments | `[]` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `8090` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts | `[{"host": "pocketbase.local", "paths": [{"path": "/", "pathType": "ImplementationSpecific"}]}]` |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### HTTPRoute Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `httpRoute.enabled` | Enable Gateway API HTTPRoute | `false` |
| `httpRoute.annotations` | HTTPRoute annotations | `{}` |
| `httpRoute.parentRefs` | Gateway references | `[{"name": "gateway", "sectionName": "http"}]` |
| `httpRoute.hostnames` | HTTPRoute hostnames | `["pocketbase.local"]` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable data persistence | `true` |
| `persistence.storageClassName` | Storage class name | `""` |
| `persistence.accessMode` | PVC access mode | `ReadWriteOnce` |
| `persistence.size` | PVC size | `1Gi` |
| `persistence.annotations` | PVC annotations | `{}` |

### Certificate Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `certificates.enabled` | Enable custom certificates | `false` |
| `certificates.files` | Certificate files as key-value pairs | `{}` |

### Other Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `resources` | Pod resource requests/limits | `{}` |
| `autoscaling.enabled` | Enable autoscaling | `false` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

## Examples

### Basic Installation with Persistence

```bash
helm install my-pocketbase ./charts/pocketbase \
  --set persistence.enabled=true \
  --set persistence.size=5Gi
```

### Installation with Admin User

```bash
helm install my-pocketbase ./charts/pocketbase \
  --set pocketbase.admin.email=admin@example.com \
  --set pocketbase.admin.password=changeme \
  --set pocketbase.encryptionKey=my-32-character-encryption-key
```

### Installation with Ingress

```bash
helm install my-pocketbase ./charts/pocketbase \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=pocketbase.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

### Installation with Custom Certificates

```yaml
# values.yaml
certificates:
  enabled: true
  files:
    ca-cert.pem: |
      -----BEGIN CERTIFICATE-----
      MIIDXTCCAkWgAwIBAgIJAKZ...
      -----END CERTIFICATE-----
```

```bash
helm install my-pocketbase ./charts/pocketbase -f values.yaml
```

### Installation with Extra Arguments

```bash
helm install my-pocketbase ./charts/pocketbase \
  --set pocketbase.extraArgs[0]=--dev \
  --set pocketbase.extraArgs[1]=--publicDir=/custom/public
```

## Security Considerations

1. **Encryption Key**: Always set a strong encryption key in production:
   ```bash
   --set pocketbase.encryptionKey=$(openssl rand -base64 32)
   ```

2. **Admin Password**: Change the default admin password or use a Kubernetes secret:
   ```bash
   kubectl create secret generic pocketbase-admin \
     --from-literal=email=admin@example.com \
     --from-literal=password=$(openssl rand -base64 32)
   ```

3. **Persistence**: Enable persistence in production to prevent data loss:
   ```bash
   --set persistence.enabled=true
   ```

4. **HTTPS**: Always use HTTPS in production with proper TLS certificates via Ingress.

## Upgrading

### To 0.34.0

This chart uses PocketBase version 0.34.0. When upgrading from previous versions, ensure:

1. Database migrations will run automatically
2. Review the [PocketBase changelog](https://github.com/pocketbase/pocketbase/releases)
3. Backup your data before upgrading

## License

This Helm chart is open source. PocketBase is licensed under the MIT License.

## Links

- [PocketBase Documentation](https://pocketbase.io/docs)
- [PocketBase GitHub](https://github.com/pocketbase/pocketbase)
- [Docker Image](https://hub.docker.com/r/adrianmusante/pocketbase)
