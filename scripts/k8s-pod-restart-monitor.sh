#!/usr/bin/env bash
# Kubernetes Pod Restart Monitor
# Monitors pods with crashloop or frequent restarts in a given namespace.

NAMESPACE="${1:-default}"
THRESHOLD="${2:-5}"

echo "=== Kubernetes Pod Restart Monitor (Namespace: $NAMESPACE, Threshold: $THRESHOLD) ==="

if ! command -v kubectl &>/dev/null; then
    echo "Error: kubectl is not installed or not in PATH" >&2
    exit 1
fi

kubectl get pods -n "$NAMESPACE" --no-headers | while read -r line; do
    NAME=$(echo "$line" | awk '{print $1}')
    STATUS=$(echo "$line" | awk '{print $3}')
    RESTARTS=$(echo "$line" | awk '{print $4}')
    
    if [[ "$STATUS" == "CrashLoopBackOff" ]] || (( RESTARTS > THRESHOLD )); then
        echo "[ALERT] Pod $NAME is in state $STATUS with $RESTARTS restarts"
    fi
done
