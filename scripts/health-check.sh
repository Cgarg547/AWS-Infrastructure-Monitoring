#!/bin/bash

set -u

PASS=0
FAIL=0

check() {
    local name="$1"
    local command="$2"

    printf "%-48s" "$name"

    if eval "$command" >/dev/null 2>&1; then
        echo "OK"
        PASS=$((PASS + 1))
    else
        echo "FAIL"
        FAIL=$((FAIL + 1))
    fi
}

echo
echo "================================================"
echo "       AWS Infrastructure Monitoring"
echo "              Health Check"
echo "================================================"
echo

echo "Docker Services"
echo "------------------------------------------------"

check "Prometheus container" \
    "docker inspect -f '{{.State.Running}}' prometheus | grep -q true"

check "Alertmanager container" \
    "docker inspect -f '{{.State.Running}}' alertmanager | grep -q true"

check "Grafana container" \
    "docker inspect -f '{{.State.Running}}' grafana | grep -q true"

check "Node Exporter container" \
    "docker inspect -f '{{.State.Running}}' node-exporter | grep -q true"

echo
echo "Service Endpoints"
echo "------------------------------------------------"

check "Prometheus ready" \
    "curl -fsS http://localhost:9090/-/ready"

check "Alertmanager ready" \
    "curl -fsS http://localhost:9093/-/ready"

check "Grafana healthy" \
    "curl -fsS http://localhost:3000/api/health"

check "Node Exporter metrics" \
    "curl -fsS http://localhost:9100/metrics"

echo
echo "Prometheus Targets"
echo "------------------------------------------------"

check "Prometheus target UP" \
    "curl -fsS 'http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22prometheus%22%7D' | grep -q '\"1\"'"

check "Node Exporter target UP" \
    "curl -fsS 'http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22node-exporter%22%7D' | grep -q '\"1\"'"

echo
echo "Prometheus Rules"
echo "------------------------------------------------"

check "Alert rules loaded" \
    "curl -fsS http://localhost:9090/api/v1/rules | grep -q 'infrastructure-alerts'"

check "Recording rules loaded" \
    "curl -fsS http://localhost:9090/api/v1/rules | grep -q 'infrastructure-recording-rules'"

echo
echo "Recording Rule Queries"
echo "------------------------------------------------"

check "CPU recording rule" \
    "curl -fsS 'http://localhost:9090/api/v1/query?query=instance%3Acpu_usage_percent' | grep -q 'node-exporter:9100'"

check "Memory recording rule" \
    "curl -fsS 'http://localhost:9090/api/v1/query?query=instance%3Amemory_usage_percent' | grep -q 'node-exporter:9100'"

check "Disk recording rule" \
    "curl -fsS 'http://localhost:9090/api/v1/query?query=instance%3Adisk_usage_percent' | grep -q 'node-exporter:9100'"

echo
echo "Alertmanager"
echo "------------------------------------------------"

check "Prometheus → Alertmanager" \
    "curl -fsS http://localhost:9090/api/v1/alertmanagers | grep -q 'alertmanager:9093'"

echo
echo "================================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo
    echo "✓ Monitoring stack is healthy."
    exit 0
else
    echo
    echo "✗ Monitoring stack has one or more failures."
    exit 1
fi
