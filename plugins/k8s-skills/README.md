# k8s-skills

Kubernetes operations and platform engineering skill for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## What it does

This plugin gives Claude deep knowledge of Kubernetes operations, covering both day-to-day troubleshooting and platform engineering:

- **Troubleshooting** — Decision trees and workflows for CrashLoopBackOff, OOMKilled, ImagePullBackOff, Pending pods, networking issues, and more
- **Manifest patterns** — Production-ready YAML templates for Deployments, Services, Ingress, HPA, PDB, NetworkPolicy, and other resources
- **Helm operations** — Chart management, values handling, Helmfile, chart authoring and testing
- **Security** — RBAC patterns, Pod Security Standards, network policies, secrets management
- **Monitoring** — Prometheus alerting rules, ServiceMonitor patterns, Grafana dashboard guidelines
- **Diagnostic scripts** — Pod diagnosis, cluster health, RBAC audit, namespace setup
- **Examples** — Complete Helm chart and multi-environment Helmfile ready to copy and customize

## Installation

```bash
# Add the CloudDrove marketplace (one-time)
/plugin marketplace add clouddrove/claude-skills

# Install the plugin
/plugin install k8s-skills@clouddrove-claude-skills
```

## Usage

Once installed, the skill triggers automatically when you mention Kubernetes-related topics:

```
> My pod is in CrashLoopBackOff
> Write a deployment manifest with HPA
> Set up RBAC for a CI/CD service account
> Help me debug why this service isn't reachable
> Create Prometheus alerting rules for my app
```

### Scripts

The plugin includes four scripts that Claude can run for you:

```bash
# Diagnose a specific pod
bash scripts/diagnose.sh -n production my-pod

# Diagnose all unhealthy pods in a namespace
bash scripts/diagnose.sh -n production --all

# Cluster health overview
bash scripts/cluster-health.sh

# Audit RBAC permissions across the cluster
bash scripts/rbac-audit.sh

# Audit a specific namespace
bash scripts/rbac-audit.sh --namespace production

# Generate production-ready namespace manifests
bash scripts/namespace-setup.sh my-namespace

# Generate and apply directly
bash scripts/namespace-setup.sh my-namespace --apply
```

### Examples

Copy and customize these real-world templates:

- **`examples/helm-chart/`** — Complete production Helm chart with Deployment, Service, Ingress, HPA, PDB, ServiceMonitor, and restricted Pod Security Standards
- **`examples/helmfile/`** — Multi-environment Helmfile (dev, staging, production) managing PostgreSQL, Redis, webapp, and kube-prometheus-stack

## Structure

```
skills/k8s/
├── SKILL.md                  # Core skill — command reference, troubleshooting tree, workflows
├── references/
│   ├── troubleshooting.md    # Detailed debugging workflows for every error state
│   ├── manifests.md          # Production-ready YAML templates
│   ├── security.md           # RBAC, Pod Security Standards, network policies
│   ├── monitoring.md         # Prometheus, Grafana, alerting rules
│   └── helm.md               # Helm operations, chart authoring, Helmfile
├── scripts/
│   ├── diagnose.sh           # Pod diagnostic tool
│   ├── cluster-health.sh     # Cluster health overview
│   ├── rbac-audit.sh         # RBAC permissions audit
│   └── namespace-setup.sh    # Production namespace generator
└── examples/
    ├── helm-chart/           # Complete production Helm chart
    └── helmfile/             # Multi-environment Helmfile setup
```

## License

Apache 2.0
