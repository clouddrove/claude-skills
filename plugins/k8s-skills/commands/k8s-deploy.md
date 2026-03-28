---
description: Deploy or rollback a Kubernetes application
argument-hint: [action] [name] [namespace]
allowed-tools: Read, Write, Edit, Bash(kubectl:*), Bash(helm:*), Bash(bash:*), Glob, Grep
---

# Deploy or Rollback a Kubernetes Application

Determine the action from the arguments. Supported actions: **apply**, **upgrade** (Helm), **rollback**, **restart**. If the action is unclear, ask the user which operation they want.

Default namespace to `default` if not specified.

## Action: Apply (kubectl)

### 1. Validate before applying

Run a diff to preview changes:

```
kubectl diff -f <manifest-file>
```

If the manifest file path is not provided, search the working directory for YAML manifests using Glob. Confirm with the user before applying.

### 2. Apply the manifest

```
kubectl apply -f <manifest-file>
```

### 3. Monitor rollout

```
kubectl rollout status deployment/<name> -n <namespace> --timeout=300s
```

Proceed to the **Verify** section below.

## Action: Helm Upgrade

### 1. Run the upgrade

Use `--atomic` so Helm auto-rolls back on failure, and `--wait` to block until healthy:

```
helm upgrade --install <release> <chart> -n <namespace> --atomic --wait --timeout 5m
```

Include any values files with `-f <values-file>` or `--set` overrides as needed.

### 2. Check release status

```
helm status <release> -n <namespace>
```

Proceed to the **Verify** section below.

## Action: Rollback

### 1. Check revision history

```
kubectl rollout history deployment/<name> -n <namespace>
```

Or for Helm:

```
helm history <release> -n <namespace>
```

### 2. Execute rollback

For kubectl, rollback to the previous or a specific revision:

```
kubectl rollout undo deployment/<name> -n <namespace>
kubectl rollout undo deployment/<name> -n <namespace> --to-revision=<N>
```

For Helm:

```
helm rollback <release> <revision> -n <namespace> --wait
```

### 3. Monitor rollback

```
kubectl rollout status deployment/<name> -n <namespace> --timeout=300s
```

Proceed to the **Verify** section below.

## Action: Restart

Perform a rolling restart (zero-downtime restart of all pods):

```
kubectl rollout restart deployment/<name> -n <namespace>
kubectl rollout status deployment/<name> -n <namespace> --timeout=300s
```

Proceed to the **Verify** section below.

## Verify (always run after any action)

### 1. Check pod health

```
kubectl get pods -n <namespace> -l app=<name>
```

Confirm all pods are Running and Ready with 0 restarts since the deploy.

### 2. Check endpoints

```
kubectl get endpoints <service-name> -n <namespace>
```

Verify that endpoints are populated (not empty). Empty endpoints mean the service selector does not match any healthy pods.

### 3. Quick log check

```
kubectl logs -l app=<name> -n <namespace> --tail=20
```

Scan for startup errors or crash indicators.

## On Failure

If any step fails or pods are unhealthy after the action, offer to run `/k8s-debug` against the failing resource to diagnose the issue.

For writing new manifests or Helm charts, reference `./references/manifests.md` and `./references/helm.md` within the k8s skill.
