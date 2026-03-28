# docker-skills

Docker operations and image optimization skill for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## What it does

This plugin gives Claude deep knowledge of Docker operations:

- **Dockerfile** — Multi-stage builds, layer caching, BuildKit, base image selection, security best practices
- **Compose** — Service definitions, networking, volumes, dev patterns, hot-reload, profiles
- **Registry** — Image tagging, push to ECR/GCR/GHCR, multi-arch builds, vulnerability scanning, image signing
- **Troubleshooting** — Container won't start, exits immediately, OOMKilled, networking, volumes, build failures
- **Diagnostic scripts** — Image audit and Compose file validation

## Installation

```bash
# Add the CloudDrove marketplace (one-time)
/plugin marketplace add clouddrove/claude-skills

# Install the plugin
/plugin install docker-skills@clouddrove-claude-skills
```

## Usage

The skill triggers automatically when you mention Docker-related topics:

```
> Write a multi-stage Dockerfile for my Node.js app
> Make my image smaller
> Why is my container crashing?
> Set up docker-compose for local dev with hot-reload
> How do I push to ECR?
```

### Slash Commands

| Command | What it does |
|---------|-------------|
| `/docker-skills:docker-debug [container]` | Diagnose container issues (inspect, logs, stats, exit codes) |
| `/docker-skills:docker-build [path]` | Build with best practices analysis and BuildKit |
| `/docker-skills:docker-optimize [image]` | Analyze image size and suggest optimizations |

### Scripts

```bash
# Audit an image for size, layers, and security
bash scripts/image-audit.sh myapp:latest

# Validate a compose file for best practices
bash scripts/compose-check.sh
bash scripts/compose-check.sh -f docker-compose.prod.yml
```

## Structure

```
commands/
├── docker-debug.md           # /docker-debug — container diagnosis
├── docker-build.md           # /docker-build — build with best practices
└── docker-optimize.md        # /docker-optimize — image optimization
skills/docker/
├── SKILL.md                  # Core skill — command reference, troubleshooting tree, workflows
├── references/
│   ├── dockerfile.md         # Multi-stage builds, caching, BuildKit, security
│   ├── compose.md            # Service patterns, networking, volumes, dev workflows
│   ├── registry.md           # Tagging, ECR/GCR/GHCR, multi-arch, scanning
│   └── troubleshooting.md    # Container debugging workflows
└── scripts/
    ├── image-audit.sh        # Image size, layers, and security audit
    └── compose-check.sh      # Compose file validation
```

## License

Apache 2.0
