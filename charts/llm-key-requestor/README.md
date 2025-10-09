# LLM Key Requestor Helm Chart

This Helm chart deploys the LLM Key Requestor application with separate frontend, backend, and admin components.

## Features

- Separate deployments for frontend, backend, and admin panel
- Three independent ingress resources (frontend, backend API, admin panel)
- Configurable admin credentials via values.yaml
- Backend configuration via ConfigMap (overridable through values.yaml)
- Support for extra environment variables via KEY: VALUE pairs
- Full support for liveness/readiness probes
- Configurable resources, autoscaling, and security contexts

## Installation

```bash
# Install with default values
helm install llm-key-requestor ./helm

# Install with custom values
helm install llm-key-requestor ./helm -f custom-values.yaml
```

## Configuration

### Admin Panel Configuration

```yaml
admin:
  enabled: true
  
  # Configure admin credentials
  # IMPORTANT: Change these in production!
  auth:
    username: "admin"
    password: "your-secure-password"
  
  image:
    repository: ghcr.io/vosiander/llm-key-requestor/admin
    tag: "latest"
  
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: admin.example.com
        paths:
          - path: /
            pathType: Prefix
```

**Setting admin credentials via command line:**

```bash
# Install with custom admin credentials
helm install llm-key-requestor ./helm \
  --set admin.auth.username=myadmin \
  --set admin.auth.password=SecurePass123!

# Or upgrade existing release
helm upgrade llm-key-requestor ./helm \
  --set admin.auth.username=myadmin \
  --set admin.auth.password=SecurePass123!
```

**⚠️ Security Note:** In production, consider using Kubernetes Secrets instead of plain values:

```bash
# Create a secret for admin credentials
kubectl create secret generic admin-credentials \
  --from-literal=username=admin \
  --from-literal=password=SecurePass123!

# Then reference it in your deployment (requires custom values)
```

### Frontend Configuration

```yaml
frontend:
  enabled: true
  image:
    repository: ghcr.io/vosiander/llm-key-requestor/frontend
    tag: "latest"
  
  # Add extra environment variables
  extraEnv:
    VITE_API_URL: "https://api.example.com"
    VITE_CUSTOM_VAR: "value"
  
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: app.example.com
        paths:
          - path: /
            pathType: Prefix
```

### Backend Configuration

```yaml
backend:
  enabled: true
  image:
    repository: ghcr.io/vosiander/llm-key-requestor/backend
    tag: "latest"
  
  # Override backend config.yaml
  config:
    litellm:
      base_url: "http://litellm:4000"
      api_key: ""
    models:
      - id: "openai-gpt4"
        title: "OpenAI GPT-4"
        icon: "simple-icons:openai"
        color: "#412991"
        description: "Advanced model"
  
  # Add extra environment variables
  extraEnv:
    LITELLM_BASE_URL: "http://custom-litellm:4000"
    LITELLM_API_KEY: "sk-custom-key"
  
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: api.example.com
        paths:
          - path: /
            pathType: Prefix
```

## Extra Environment Variables

Both frontend and backend support adding extra environment variables using the `extraEnv` map:

```yaml
frontend:
  extraEnv:
    KEY1: "value1"
    KEY2: "value2"

backend:
  extraEnv:
    KEY3: "value3"
    KEY4: "value4"
```

## Ingress Configuration

The chart creates three separate ingress resources:
- `<release-name>-frontend` for the frontend application
- `<release-name>-backend` for the backend API
- `<release-name>-admin` for the admin panel

Example with TLS:

```yaml
frontend:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - host: app.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: frontend-tls
        hosts:
          - app.example.com

backend:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - host: api.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: backend-tls
        hosts:
          - api.example.com

admin:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - host: admin.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: admin-tls
        hosts:
          - admin.example.com
```

## Backend Configuration Override

The backend's `config.yaml` is generated from `backend.config` in values.yaml. You can override the entire configuration or specific parts:

```yaml
backend:
  config:
    litellm:
      base_url: "http://my-litellm:4000"
      api_key: "my-secret-key"
    models:
      - id: "custom-model"
        title: "My Custom Model"
        icon: "mdi:robot"
        color: "#FF0000"
        description: "Custom model description"
```

## Testing

```bash
# Lint the chart
helm lint ./helm

# Test rendering
helm template test-release ./helm --dry-run

# Test with custom values
helm template test-release ./helm -f custom-values.yaml --dry-run

# Run tests after installation
helm test <release-name>
```

## Uninstallation

```bash
helm uninstall llm-key-requestor
```

## Values

See [values.yaml](./values.yaml) for all configurable parameters.
