---
description: Check cluster or namespace health
argument-hint: [namespace]
allowed-tools: Read, Bash(kubectl:*), Bash(bash:*), Grep
---

# Check Cluster or Namespace Health

If a namespace argument is provided, scope all checks to that namespace. Otherwise, check the entire cluster.

## Step 1: Run Health Script (if available)

If `scripts/cluster-health.sh` is available, prefer running it for a comprehensive report:

```
bash scripts/cluster-health.sh
```

Or for a specific context:

```
bash scripts/cluster-health.sh --context <context-name>
```

Run with `--help` first if unsure of usage. If the script is not available, proceed with the manual checks below.

## Step 2: Node Status

Check that all nodes are Ready:

```
kubectl get nodes -o wide
```

Flag any nodes showing NotReady, SchedulingDisabled, or with conditions like MemoryPressure, DiskPressure, or PIDPressure.

## Step 3: Resource Utilization

Check node-level resource usage:

```
kubectl top nodes
```

Flag nodes above 85% CPU or memory utilization -- these are at risk of scheduling failures and OOM evictions.

## Step 4: Unhealthy Pods

Find pods that are not in Running/Succeeded state:

For a specific namespace:

```
kubectl get pods -n <namespace> --field-selector status.phase!=Running,status.phase!=Succeeded
```

For the entire cluster:

```
kubectl get pods -A --field-selector status.phase!=Running,status.phase!=Succeeded
```

Also check for pods with high restart counts:

```
kubectl get pods -n <namespace> --sort-by='.status.containerStatuses[0].restartCount'
```

(Use `-A` instead of `-n <namespace>` for cluster-wide checks.)

## Step 5: Pending PVCs

Find PersistentVolumeClaims that are not bound:

```
kubectl get pvc -A --field-selector status.phase!=Bound
```

Or scoped to a namespace:

```
kubectl get pvc -n <namespace> --field-selector status.phase!=Bound
```

Pending PVCs block pods that depend on them.

## Step 6: Recent Warning Events

Pull recent warning-level events to surface emerging problems:

```
kubectl get events -A --field-selector type=Warning --sort-by=.lastTimestamp | tail -30
```

Or scoped to a namespace:

```
kubectl get events -n <namespace> --field-selector type=Warning --sort-by=.lastTimestamp | tail -20
```

Look for patterns: repeated FailedScheduling, BackOff, Unhealthy, FailedMount, etc.

## Step 7: Deployment Replica Mismatches

Check for deployments where desired replicas do not match available replicas:

For a specific namespace:

```
kubectl get deployments -n <namespace> -o custom-columns=NAME:.metadata.name,DESIRED:.spec.replicas,READY:.status.readyReplicas,AVAILABLE:.status.availableReplicas
```

For the entire cluster:

```
kubectl get deployments -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,DESIRED:.spec.replicas,READY:.status.readyReplicas,AVAILABLE:.status.availableReplicas
```

Flag any deployment where READY or AVAILABLE does not match DESIRED.

## Step 8: Summarize Findings

Present a clear health summary using these indicators:

- **PASS** -- Everything healthy, no action needed.
- **WARN** -- Non-critical issues found (e.g., high resource usage, pods with elevated restart counts, minor event warnings).
- **FAIL** -- Critical issues requiring immediate attention (e.g., NotReady nodes, CrashLooping pods, unbound PVCs blocking workloads, replica mismatches).

Structure the summary as a table or checklist:

| Check                    | Status | Details                         |
|--------------------------|--------|---------------------------------|
| Node health              | PASS   | All 3 nodes Ready               |
| Resource utilization     | WARN   | node-2 at 87% memory            |
| Unhealthy pods           | FAIL   | 2 pods in CrashLoopBackOff      |
| Pending PVCs             | PASS   | None                            |
| Warning events           | WARN   | 5 FailedScheduling in last hour |
| Deployment replicas      | PASS   | All deployments at desired count |

## Step 9: Suggest Next Steps

For any WARN or FAIL findings, suggest concrete next steps:

- Unhealthy pods: Offer to run `/k8s-debug` on the specific pod.
- Node issues: Suggest `kubectl describe node <node>` to inspect conditions.
- Resource pressure: Suggest reviewing resource requests/limits or scaling the node pool.
- PVC issues: Suggest checking StorageClass availability and provisioner status.
- Replica mismatches: Suggest checking events on the deployment and related ReplicaSet.

If the user wants a security posture check, offer to run `scripts/rbac-audit.sh` for a cluster-wide RBAC audit.
