---
description: Debug a Docker container issue
argument-hint: [container-name]
allowed-tools: Read, Bash(docker:*), Bash(bash:*), Grep
---

# Debug a Docker Container Issue

If no arguments were provided, list running containers and recently exited containers so the user can pick one:

```
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
docker ps -a --filter status=exited --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | head -20
```

Ask the user which container they want to debug if the target is unclear.

## Step 1: Container Status

Get the full container state via inspect:

```
docker inspect <container>
```

Check the following from the output:
- **State.Status** -- running, exited, paused, restarting, dead
- **State.ExitCode** -- non-zero means abnormal termination
- **State.OOMKilled** -- true means the container ran out of memory
- **State.Error** -- any error message from the runtime
- **RestartCount** -- high values indicate a crash loop

## Step 2: Check Logs

Pull recent logs from the container:

```
docker logs <container> --tail=100
```

If the container is restarting, also check with timestamps to correlate events:

```
docker logs <container> --tail=100 --timestamps
```

Look for stack traces, error messages, connection failures, or permission denied errors.

## Step 3: Resource Usage (if running)

If the container is currently running, check resource consumption:

```
docker stats <container> --no-stream
```

Compare actual memory usage against any limits set. Check if CPU is pegged at the limit.

Also check the container's resource constraints:

```
docker inspect <container> --format '{{.HostConfig.Memory}} {{.HostConfig.NanoCpus}} {{.HostConfig.MemoryReservation}}'
```

## Step 4: Process and Network State (if running)

If the container is running, check what is happening inside:

```
docker top <container>
```

Check network connectivity and port bindings:

```
docker port <container>
docker inspect <container> --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

## Step 5: Exit Analysis (if exited)

If the container has exited, analyze the exit code:

- **Exit 0** -- Normal termination (check if it should still be running)
- **Exit 1** -- Application error (check logs for the error)
- **Exit 137** -- SIGKILL (OOMKilled or `docker kill`)
- **Exit 139** -- SIGSEGV (segmentation fault)
- **Exit 143** -- SIGTERM (graceful shutdown via `docker stop`)

Check when it exited:

```
docker inspect <container> --format '{{.State.StartedAt}} -> {{.State.FinishedAt}}'
```

## Step 6: Image Audit (optional)

If the issue may be related to the image itself, offer to run the image audit script:

```
bash scripts/image-audit.sh <image-name>
```

Run with `--help` first if unsure of usage.

## Step 7: Analyze and Diagnose

Synthesize all gathered information and provide:

1. **Root cause** -- What is actually wrong (e.g., OOMKilled, application crash, misconfiguration, missing environment variable, port conflict).
2. **Evidence** -- The specific log lines, inspect fields, or metrics that point to the cause.
3. **Suggested fix** -- Concrete actions to resolve the issue (with example commands).
4. **Prevention** -- What to add or change to prevent recurrence (healthchecks, resource limits, restart policies).

For deeper analysis, reference the troubleshooting guide at `./references/troubleshooting.md` within the docker skill.
