---
description: Build a Docker image with best practices
argument-hint: [path-or-dockerfile]
allowed-tools: Read, Write, Edit, Bash(docker:*), Bash(bash:*), Glob, Grep
---

# Build a Docker Image with Best Practices

If a path or Dockerfile is provided as an argument, use it. Otherwise, search the current directory for a Dockerfile.

## Step 1: Locate the Dockerfile

If no argument was given, search for a Dockerfile:

```
ls Dockerfile Dockerfile.* *.dockerfile 2>/dev/null
```

If no Dockerfile exists, ask the user if they want to create one. If yes, ask about the application language/framework and generate an appropriate Dockerfile following best practices from `./references/dockerfile.md`.

## Step 2: Analyze the Dockerfile

Read the Dockerfile and check for best practices:

1. **Base image** -- Is it pinned to a specific version? Is it a minimal image (alpine, slim, distroless)?
2. **Layer ordering** -- Are layers ordered from least-frequently-changed to most-frequently-changed? (system deps before app code)
3. **Multi-stage build** -- Is a multi-stage build used to separate build dependencies from the runtime image?
4. **Cache efficiency** -- Are package manager lockfiles (package.json, requirements.txt, go.sum) copied before the full source code?
5. **Security** -- Does it run as a non-root user? Are there any secrets baked into the image?
6. **Cleanup** -- Are package caches cleaned up in the same layer as the install?
7. **.dockerignore** -- Does a .dockerignore file exist? Does it exclude node_modules, .git, build artifacts?

Report findings and suggest improvements. Reference `./references/dockerfile.md` for recommended patterns.

## Step 3: Build the Image

Determine a suitable image name from the directory name or Dockerfile content, or ask the user. Build with BuildKit enabled:

```
DOCKER_BUILDKIT=1 docker build -t <name> -f <dockerfile> .
```

If the user provided a specific path, use that as the build context.

## Step 4: Post-Build Analysis

After a successful build, check the resulting image size:

```
docker image inspect <name> --format '{{.Size}}'
```

Report the size in human-readable format. If the image exceeds 500 MB, suggest running the image audit for detailed optimization guidance:

```
bash scripts/image-audit.sh <name>
```

## Step 5: Handle Build Failures

If the build fails, diagnose the error:

1. **Syntax errors** -- Point to the specific line in the Dockerfile
2. **Package not found** -- Check package name, suggest alternatives, verify base image has the package manager
3. **Permission denied** -- Check file permissions, USER instruction placement
4. **Network errors** -- Suggest checking proxy settings or DNS, or using `--network=host` for the build
5. **Out of disk space** -- Suggest `docker system prune` to reclaim space
6. **Multi-platform issues** -- Check if the base image supports the target architecture

Suggest the specific fix and offer to apply it to the Dockerfile.

## Step 6: Summary

Provide a summary with:
- Image name and tag
- Final image size
- Number of layers
- Any remaining optimization suggestions
- Next steps (run, push to registry, add to compose file)
