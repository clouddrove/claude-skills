---
description: Analyze and optimize a Docker image
argument-hint: [image-name]
allowed-tools: Read, Write, Edit, Bash(docker:*), Bash(bash:*), Glob, Grep
---

# Analyze and Optimize a Docker Image

If an image name is provided as an argument, use it. Otherwise, list local images and ask the user which one to optimize:

```
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" | head -20
```

## Step 1: Run Image Audit

If the `scripts/image-audit.sh` script is available, run it for a comprehensive analysis:

```
bash scripts/image-audit.sh <image-name>
```

Run with `--help` first if unsure of usage.

If the script is not available, run the equivalent commands manually:

```
docker image inspect <image-name> --format '{{.Size}}'
docker history <image-name> --no-trunc
```

Record the **before** image size for later comparison.

## Step 2: Analyze Image Layers

Examine the layer breakdown in detail:

```
docker history <image-name> --format "{{.Size}}\t{{.CreatedBy}}" --no-trunc
```

Identify:
- Layers that are disproportionately large
- Redundant layers (e.g., separate RUN commands that could be combined)
- Package manager caches not cleaned up
- Unnecessary files copied into the image
- Build tools or compilers present in the final image

## Step 3: Find and Analyze Dockerfile

Search for a Dockerfile in the current directory:

```
ls Dockerfile Dockerfile.* *.dockerfile 2>/dev/null
```

If found, read it and produce specific, actionable optimization recommendations:

### Base Image Optimization
- If using a full OS image (ubuntu, debian), suggest switching to a slim or alpine variant
- Provide a size comparison: `docker pull <alternative> && docker image inspect <alternative> --format '{{.Size}}'`
- If the application is compiled (Go, Rust, C), suggest distroless or scratch as the final stage

### Multi-Stage Build
- If the Dockerfile is single-stage with build tools, suggest converting to multi-stage
- Provide the specific multi-stage pattern for the detected language/framework
- Separate build dependencies from runtime dependencies

### Layer Optimization
- Identify RUN commands that should be combined with `&&`
- Move dependency installation before source code copy for better caching
- Ensure package manager cleanup happens in the same RUN layer as install
- For apt: `apt-get install -y --no-install-recommends <pkg> && rm -rf /var/lib/apt/lists/*`
- For apk: `apk add --no-cache <pkg>`
- For pip: `pip install --no-cache-dir -r requirements.txt`

### .dockerignore
- Check if `.dockerignore` exists
- If missing, create one with sensible defaults for the detected project type
- Common exclusions: `.git`, `node_modules`, `__pycache__`, `*.pyc`, `.env`, build artifacts

### Security Hardening
- Add a non-root USER if not present
- Remove unnecessary setuid/setgid binaries
- Use COPY instead of ADD unless tar extraction is needed

## Step 4: Apply Optimizations

Offer to apply the suggested optimizations directly to the Dockerfile. Make changes incrementally and explain each one. Key changes to apply:

1. Switch base image (if applicable)
2. Add multi-stage build (if applicable)
3. Reorder and combine layers
4. Add cleanup commands
5. Create or update .dockerignore
6. Add non-root user

## Step 5: Rebuild and Compare

After applying optimizations, rebuild the image:

```
DOCKER_BUILDKIT=1 docker build -t <image-name>:optimized -f <dockerfile> .
```

Compare before and after:

```
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep <image-name>
```

Report the size reduction in both absolute (MB) and relative (%) terms.

## Step 6: Summary

Provide a final report with:
- **Before** size and layer count
- **After** size and layer count
- Size reduction achieved
- List of optimizations applied
- Any remaining suggestions that could not be automated

Reference `./references/dockerfile.md` for additional optimization patterns and best practices.
