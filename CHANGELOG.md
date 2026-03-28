# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-28

### Added

- **k8s-skills plugin** — Kubernetes operations, troubleshooting, and platform engineering
  - `SKILL.md` with kubectl command reference, pod troubleshooting decision tree, deployment workflow, emergency procedures, and Helm quick reference
  - `references/troubleshooting.md` — debugging workflows for CrashLoopBackOff, OOMKilled, ImagePullBackOff, Pending, node issues, networking, and storage
  - `references/manifests.md` — production-ready YAML patterns for Deployments, Services, Ingress, HPA, PDB, NetworkPolicy, ConfigMap, Secret, and more
  - `references/security.md` — RBAC patterns, Pod Security Standards, network policies, secrets management
  - `references/monitoring.md` — Prometheus alerting rules, ServiceMonitor patterns, Grafana dashboard guidelines
  - `references/helm.md` — Helm operations, chart structure, values management, Helmfile, testing
  - `scripts/diagnose.sh` — pod diagnostic tool with structured output and suggested fixes
  - `scripts/cluster-health.sh` — cluster health overview (nodes, resources, unhealthy pods, events)
  - `scripts/rbac-audit.sh` — RBAC audit for cluster-admin bindings, wildcard permissions, default SA usage
  - `scripts/namespace-setup.sh` — generate production-ready namespace manifests (PSS, quotas, network policies)
  - `examples/helm-chart/` — complete production Helm chart with HPA, PDB, ServiceMonitor, restricted PSS
  - `examples/helmfile/` — multi-environment Helmfile (dev, staging, production) with PostgreSQL, Redis, webapp, prometheus-stack

[0.1.0]: https://github.com/clouddrove/claude-skills/releases/tag/v0.1.0
