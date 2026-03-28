#!/usr/bin/env bash
set -euo pipefail

# Pod diagnostic script for Kubernetes
# Checks status, events, logs, resources, and suggests fixes

VERSION="0.1.0"
NAMESPACE=""
POD_NAME=""
ALL_PODS=false
TAIL_LINES=50

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

usage() {
    cat <<EOF
Usage: $(basename "$0") [-n namespace] [--all | <pod-name>]

Diagnose Kubernetes pod issues with structured output and suggested fixes.

Arguments:
  <pod-name>           Name of the pod to diagnose

Options:
  -n, --namespace NS   Target namespace (default: current context namespace)
  -a, --all            Diagnose all non-running pods in namespace
  --tail N             Number of log lines to fetch (default: 50)
  -h, --help           Show this help
  -v, --version        Show version

Examples:
  $(basename "$0") my-pod
  $(basename "$0") -n production my-pod
  $(basename "$0") -n production --all
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace) NAMESPACE="$2"; shift 2 ;;
        -a|--all) ALL_PODS=true; shift ;;
        --tail) TAIL_LINES="$2"; shift 2 ;;
        -h|--help) usage ;;
        -v|--version) echo "diagnose.sh v${VERSION}"; exit 0 ;;
        -*) echo "Unknown option: $1" >&2; exit 1 ;;
        *) POD_NAME="$1"; shift ;;
    esac
done

if [[ -z "$POD_NAME" && "$ALL_PODS" == false ]]; then
    echo "Error: Provide a pod name or use --all" >&2
    echo "Run with --help for usage" >&2
    exit 1
fi

# Check dependencies
if ! command -v kubectl &>/dev/null; then
    echo "Error: kubectl not found in PATH" >&2
    exit 1
fi

NS_FLAG=""
if [[ -n "$NAMESPACE" ]]; then
    NS_FLAG="-n $NAMESPACE"
fi

section() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━ $1 ━━━${NC}"
}

warn() { echo -e "${YELLOW}⚠  $1${NC}"; }
fail() { echo -e "${RED}✗  $1${NC}"; }
pass() { echo -e "${GREEN}✓  $1${NC}"; }

diagnose_pod() {
    local pod="$1"

    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  Diagnosing: ${pod}${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"

    # --- STATUS ---
    section "STATUS"
    local status_json
    status_json=$(kubectl get pod "$pod" $NS_FLAG -o json 2>/dev/null) || {
        fail "Pod not found: $pod"
        return 1
    }

    local phase ready restarts reason
    phase=$(echo "$status_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['status'].get('phase','Unknown'))" 2>/dev/null || echo "Unknown")
    ready=$(echo "$status_json" | python3 -c "
import sys,json
d=json.load(sys.stdin)
cs=d['status'].get('containerStatuses',[])
ready=sum(1 for c in cs if c.get('ready'))
total=len(cs)
print(f'{ready}/{total}')
" 2>/dev/null || echo "?/?")
    restarts=$(echo "$status_json" | python3 -c "
import sys,json
d=json.load(sys.stdin)
cs=d['status'].get('containerStatuses',[])
print(sum(c.get('restartCount',0) for c in cs))
" 2>/dev/null || echo "0")

    echo "  Phase:    $phase"
    echo "  Ready:    $ready"
    echo "  Restarts: $restarts"

    # Check container statuses for issues
    local container_issues
    container_issues=$(echo "$status_json" | python3 -c "
import sys,json
d=json.load(sys.stdin)
for cs_type in ['initContainerStatuses','containerStatuses']:
    for c in d['status'].get(cs_type,[]):
        name=c['name']
        state=c.get('state',{})
        if 'waiting' in state:
            r=state['waiting'].get('reason','Unknown')
            m=state['waiting'].get('message','')
            print(f'  WAITING  {name}: {r} {m}')
        elif 'terminated' in state:
            r=state['terminated'].get('reason','Unknown')
            code=state['terminated'].get('exitCode','?')
            print(f'  TERMINATED  {name}: {r} (exit code {code})')
" 2>/dev/null || echo "")

    if [[ -n "$container_issues" ]]; then
        echo ""
        echo "  Container Issues:"
        echo "$container_issues"
    fi

    # --- EVENTS ---
    section "EVENTS (last 10)"
    kubectl get events $NS_FLAG \
        --field-selector "involvedObject.name=$pod" \
        --sort-by=.lastTimestamp 2>/dev/null | tail -12 || warn "Could not fetch events"

    # --- LOGS ---
    section "LOGS (last ${TAIL_LINES} lines)"
    local containers
    containers=$(echo "$status_json" | python3 -c "
import sys,json
d=json.load(sys.stdin)
for c in d['spec']['containers']:
    print(c['name'])
" 2>/dev/null || echo "")

    for container in $containers; do
        echo -e "  ${BOLD}Container: ${container}${NC}"

        # Current logs
        local logs
        logs=$(kubectl logs "$pod" $NS_FLAG -c "$container" --tail="$TAIL_LINES" 2>&1) || true
        if [[ -n "$logs" ]]; then
            echo "$logs" | head -20
            local total_lines
            total_lines=$(echo "$logs" | wc -l | tr -d ' ')
            if [[ "$total_lines" -gt 20 ]]; then
                echo "  ... ($total_lines lines total, showing first 20)"
            fi
        else
            warn "No current logs"
        fi

        # Previous container logs (if restarts > 0)
        if [[ "$restarts" -gt 0 ]]; then
            echo -e "  ${BOLD}Previous container logs:${NC}"
            local prev_logs
            prev_logs=$(kubectl logs "$pod" $NS_FLAG -c "$container" --previous --tail=20 2>&1) || true
            if [[ -n "$prev_logs" && "$prev_logs" != *"previous terminated container"*"not found"* ]]; then
                echo "$prev_logs" | head -10
            else
                warn "No previous logs available"
            fi
        fi
        echo ""
    done

    # --- RESOURCE CHECK ---
    section "RESOURCE CHECK"
    local resources
    resources=$(echo "$status_json" | python3 -c "
import sys,json
d=json.load(sys.stdin)
for c in d['spec']['containers']:
    name=c['name']
    res=c.get('resources',{})
    req=res.get('requests',{})
    lim=res.get('limits',{})
    req_cpu=req.get('cpu','<not set>')
    req_mem=req.get('memory','<not set>')
    lim_cpu=lim.get('cpu','<not set>')
    lim_mem=lim.get('memory','<not set>')
    print(f'  {name}:')
    print(f'    Requests: cpu={req_cpu}, memory={req_mem}')
    print(f'    Limits:   cpu={lim_cpu}, memory={lim_mem}')
" 2>/dev/null || echo "  Could not parse resources")
    echo "$resources"

    # Check for missing requests/limits
    echo "$status_json" | python3 -c "
import sys,json
d=json.load(sys.stdin)
for c in d['spec']['containers']:
    res=c.get('resources',{})
    if not res.get('requests') and not res.get('limits'):
        print(f'  WARNING: {c[\"name\"]} has no resource requests or limits (BestEffort QoS)')
    elif not res.get('limits'):
        print(f'  WARNING: {c[\"name\"]} has no resource limits')
    elif not res.get('requests'):
        print(f'  WARNING: {c[\"name\"]} has no resource requests')
" 2>/dev/null || true

    # --- DIAGNOSIS ---
    section "DIAGNOSIS & SUGGESTED ACTIONS"

    local has_suggestion=false

    # CrashLoopBackOff
    if echo "$container_issues" | grep -q "CrashLoopBackOff" 2>/dev/null; then
        has_suggestion=true
        fail "CrashLoopBackOff detected"
        echo "  → Check logs above for the crash reason"
        echo "  → If OOMKilled (exit code 137): increase memory limits"
        echo "  → If exit code 1: fix application error shown in logs"
        echo "  → If probe failure: adjust initialDelaySeconds or fix health endpoint"
    fi

    # OOMKilled
    if echo "$container_issues" | grep -q "OOMKilled" 2>/dev/null; then
        has_suggestion=true
        fail "OOMKilled detected — container exceeded memory limit"
        echo "  → Increase spec.containers[].resources.limits.memory"
        echo "  → Check for memory leaks in application"
        echo "  → Current limits shown in RESOURCE CHECK above"
    fi

    # ImagePullBackOff
    if echo "$container_issues" | grep -q "ImagePull\|ErrImagePull" 2>/dev/null; then
        has_suggestion=true
        fail "Image pull failure detected"
        echo "  → Verify image name and tag exist in registry"
        echo "  → Check imagePullSecrets: kubectl get pod $pod $NS_FLAG -o jsonpath='{.spec.imagePullSecrets}'"
        echo "  → Check node network access to registry"
    fi

    # Pending
    if [[ "$phase" == "Pending" ]]; then
        has_suggestion=true
        warn "Pod is Pending — not yet scheduled"
        echo "  → Check events above for scheduling failure reason"
        echo "  → Check node capacity: kubectl describe nodes | grep -A5 'Allocated'"
        echo "  → Check PVC status: kubectl get pvc $NS_FLAG"
    fi

    # High restarts
    if [[ "$restarts" -gt 5 ]]; then
        has_suggestion=true
        warn "High restart count: $restarts"
        echo "  → Pod is repeatedly crashing — investigate logs above"
        echo "  → Consider scaling to 0 temporarily while investigating"
    fi

    # No resource limits
    if echo "$status_json" | python3 -c "
import sys,json
d=json.load(sys.stdin)
for c in d['spec']['containers']:
    if not c.get('resources',{}).get('limits'):
        sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
        has_suggestion=true
        warn "Missing resource limits on one or more containers"
        echo "  → Set resource requests and limits to prevent OOM and ensure proper scheduling"
    fi

    if [[ "$has_suggestion" == false ]]; then
        if [[ "$phase" == "Running" && "$ready" != *"/0"* ]]; then
            pass "Pod appears healthy"
        else
            warn "No specific issue pattern detected — review events and logs above"
        fi
    fi
}

# Main execution
if [[ "$ALL_PODS" == true ]]; then
    echo -e "${BOLD}Scanning for non-running pods...${NC}"
    non_running=$(kubectl get pods $NS_FLAG --field-selector 'status.phase!=Running,status.phase!=Succeeded' -o name 2>/dev/null | sed 's|pod/||')

    if [[ -z "$non_running" ]]; then
        pass "All pods are running or completed"
        exit 0
    fi

    count=$(echo "$non_running" | wc -l | tr -d ' ')
    echo "Found $count non-running pod(s)"

    for pod in $non_running; do
        diagnose_pod "$pod"
    done
else
    diagnose_pod "$POD_NAME"
fi
