---
description: Debug a Kubernetes pod or deployment
argument-hint: [resource-name] [namespace]
allowed-tools: Read, Bash(kubectl:*), Bash(bash:*), Grep
---

# Debug a Kubernetes Pod or Deployment

If no arguments were provided, ask the user what resource they want to debug (pod name, deployment name) and which namespace it is in. Default namespace to `default` if not specified.

## Step 1: Check Resource Status

Determine whether the target is a pod or deployment. Run:

```
kubectl get pod <name> -n <namespace> -o wide
```

If that fails, try as a deployment:

```
kubectl get deployment <name> -n <namespace> -o wide
kubectl get pods -l app=<name> -n <namespace> -o wide
```

Note the pod status, restarts, node assignment, and age.

## Step 2: Describe the Resource

Run `kubectl describe` on the resource to inspect events, conditions, and configuration:

```
kubectl describe pod <name> -n <namespace>
```

Or for a deployment:

```
kubectl describe deployment <name> -n <namespace>
```

Pay close attention to the **Events** section at the bottom -- this is where scheduling failures, image pull errors, probe failures, and OOM kills surface.

## Step 3: Check Logs

Pull recent logs from the pod:

```
kubectl logs <pod> -n <namespace> --tail=100
```

If the pod has multiple containers, check each one with `-c <container>`.

If the restart count is greater than 0, also check previous container logs:

```
kubectl logs <pod> -n <namespace> --previous --tail=100
```

## Step 4: Check Resource Usage

Run `kubectl top` to check CPU and memory consumption:

```
kubectl top pod <pod> -n <namespace>
```

Compare actual usage against the resource requests/limits shown in the describe output. Look for OOMKilled signals or CPU throttling.

## Step 5: Run Diagnostic Script (if available)

If the skill's `scripts/diagnose.sh` is available, offer to run it for a comprehensive diagnosis:

```
bash scripts/diagnose.sh -n <namespace> <pod-name>
```

Run with `--help` first if unsure of usage.

## Step 6: Analyze and Diagnose

Synthesize all gathered information and provide:

1. **Root cause** -- What is actually wrong (e.g., OOMKilled, failing liveness probe, image not found, missing config, insufficient resources for scheduling).
2. **Evidence** -- The specific log lines, events, or metrics that point to the cause.
3. **Suggested fixes** -- Concrete actions to resolve the issue (with example commands or manifest changes).
4. **Prevention** -- What to add or change to prevent recurrence (probes, resource limits, PDBs).

For deeper analysis of specific error states (CrashLoopBackOff, ImagePullBackOff, Pending, Evicted), reference the troubleshooting guide at `./references/troubleshooting.md` within the k8s skill.
