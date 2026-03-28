<p align="center">
  <a href="https://github.com/clouddrove/claude-skills/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-Apache%202.0-blue.svg" alt="License: Apache 2.0">
  </a>
  <a href="https://github.com/clouddrove/claude-skills">
    <img src="https://img.shields.io/badge/version-0.1.0-green.svg" alt="Version: 0.1.0">
  </a>
  <a href="https://github.com/clouddrove/claude-skills">
    <img src="https://img.shields.io/badge/claude--code-plugin-7C3AED.svg" alt="Claude Code Plugin">
  </a>
</p>

# CloudDrove Claude Skills

A curated collection of DevOps skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — the CLI tool by Anthropic. These skills extend Claude with deep domain knowledge for Kubernetes, Terraform, AWS, and other infrastructure tools.

## What are Skills?

Skills are structured knowledge packs that Claude Code loads on demand. When you ask Claude a Kubernetes question, the k8s skill automatically activates — giving Claude access to troubleshooting workflows, manifest patterns, Helm guides, security references, and diagnostic scripts without you having to provide any context.

## Available Plugins

| Plugin | Description | Status |
|--------|-------------|--------|
| [**k8s-skills**](./plugins/k8s-skills) | Kubernetes operations, troubleshooting, and platform engineering | :white_check_mark: Available |
| **terraform-skills** | Terraform modules, state management, and IaC patterns | :construction: Planned |
| **aws-skills** | AWS services, architecture, and operations | :construction: Planned |
| **docker-skills** | Docker, container builds, and optimization | :construction: Planned |

## Quick Start

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and configured

### Installation

```bash
# 1. Add the CloudDrove marketplace (one-time)
/plugin marketplace add clouddrove/claude-skills

# 2. Install the plugins you need
/plugin install k8s-skills@clouddrove-claude-skills
```

### Usage

Once installed, skills trigger automatically based on context. Just ask naturally:

```
> My pod is stuck in CrashLoopBackOff, how do I debug it?
> Write a production-ready Deployment with HPA and PDB
> Set up RBAC for a CI/CD service account
> Create Prometheus alerting rules for pod failures
> Help me write a Helm chart for my app
> Set up a new namespace with quotas and network policies
> Audit RBAC permissions in my cluster
```

## k8s-skills

The Kubernetes skill covers both day-to-day operations and platform engineering:

| Area | What's Included |
|------|----------------|
| **Troubleshooting** | Decision trees for CrashLoopBackOff, OOMKilled, ImagePullBackOff, Pending, networking, storage |
| **Manifests** | Production-ready YAML for Deployments, Services, Ingress, HPA, PDB, NetworkPolicy, and more |
| **Helm** | Chart management, values handling, Helmfile, chart authoring, testing |
| **Security** | RBAC patterns, Pod Security Standards, network policies, secrets management |
| **Monitoring** | Prometheus alerting rules, ServiceMonitor patterns, Grafana dashboards, USE/RED methods |
| **Scripts** | `diagnose.sh`, `cluster-health.sh`, `rbac-audit.sh`, `namespace-setup.sh` |
| **Examples** | Complete Helm chart, multi-environment Helmfile (dev/staging/prod) |

<details>
<summary>Directory structure</summary>

```
plugins/k8s-skills/
├── skills/k8s/
│   ├── SKILL.md                  # Core skill — command reference, troubleshooting tree, workflows
│   ├── references/
│   │   ├── troubleshooting.md    # Detailed debugging workflows for every error state
│   │   ├── manifests.md          # Production-ready YAML templates
│   │   ├── security.md           # RBAC, Pod Security Standards, network policies
│   │   ├── monitoring.md         # Prometheus, Grafana, alerting rules
│   │   └── helm.md               # Helm operations, chart authoring, Helmfile
│   ├── scripts/
│   │   ├── diagnose.sh           # Pod diagnostic tool
│   │   ├── cluster-health.sh     # Cluster health overview
│   │   ├── rbac-audit.sh         # RBAC permissions audit
│   │   └── namespace-setup.sh    # Production namespace generator
│   └── examples/
│       ├── helm-chart/           # Complete production Helm chart
│       └── helmfile/             # Multi-environment Helmfile setup
└── README.md
```

</details>

## Contributing

Contributions are welcome! Whether it's improving existing skills or adding new ones.

### Adding a New Skill

1. Fork and clone this repository
2. Create your skill directory under `plugins/<plugin-name>/skills/<skill-name>/`
3. Write a `SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: my-skill
   description: "When to trigger this skill and what it does..."
   ---

   # Skill instructions here
   ```
4. Add reference docs in `references/` and scripts in `scripts/` as needed
5. Register the plugin in `.claude-plugin/marketplace.json`
6. Submit a pull request

### Improving an Existing Skill

- Fix inaccuracies, add missing patterns, improve troubleshooting workflows
- Add new reference docs for uncovered topics
- Improve script diagnostics and output

### Guidelines

- Keep `SKILL.md` lean (under 500 lines) — move detailed content to `references/`
- Write in imperative/third-person style for AI consumption
- Include working examples, not pseudo-code
- Scripts should support `--help` and work as black-box tools

## How It Works

Skills use a three-level progressive loading system:

1. **Metadata** — Skill name and description are always loaded (~100 words). Claude uses this to decide when to activate.
2. **SKILL.md** — Core instructions loaded when the skill triggers. Contains quick references, decision trees, and pointers to deeper docs.
3. **References** — Detailed guides loaded on demand. Only pulled into context when needed for a specific task.

This keeps Claude's context efficient while making deep knowledge available when needed.

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.

## About CloudDrove

[CloudDrove](https://clouddrove.com) is a DevOps consultancy helping teams build and scale cloud infrastructure. We build open-source tools for the community.

- [Website](https://clouddrove.com)
- [GitHub](https://github.com/clouddrove)
- [Terraform Modules](https://github.com/clouddrove?q=terraform&type=all)
