#!/bin/bash

set -u

PASS=0
FAIL=0

check() {
    local name="$1"
    local command="$2"

    printf "%-45s" "$name"

    if eval "$command" >/dev/null 2>&1; then
        echo "OK"
        PASS=$((PASS + 1))
    else
        echo "FAIL"
        FAIL=$((FAIL + 1))
    fi
}

echo "=============================================="
echo "      AWS Monitoring Stack Health Check"
echo "=============================================="
echo

echo "Docker Services"
echo "----------------------------------------------"

check "Prometheus container" \
    "docker inspect -f '{{.State.Running}}' prometheus | grep -q true"

check "Alertmanager container" \
    "docker inspect -f '{{.State.Running}}' alertmanager | grep -q true"

check "Grafana container" \
    "docker inspect -f '{{.State.Running}}' grafana | grep -q true"

check "Node Exporter container" \
    "docker inspect -f '{{.State.Running}}' node-exporter | grep -q true"

echo
echo "HTTP Services"
echo "----------------------------------------------"

check "Prometheus API" \
    "curl -fsS http://localhost:9090/-/ready"

check "Alertmanager API" \
    "curl -fsS http://localhost:9093/-/ready"

check "Grafana API" \
    "curl -fsS http://localhost:3000/api/health"

check "Node Exporter metrics" \
    "curl -fsS http://localhost:9100/metrics"

echo
echo "Prometheus"
echo "----------------------------------------------"

check "Node Exporter target is UP" \
    "curl -fsS 'http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22node-exporter%22%7D' | grep -q '\"1\"'"

check "Prometheus target is UP" \
    "curl -fsS 'http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22prometheus%22%7D' | grep -q '\"1\"'"

check "Alert rules loaded" \
    "curl -fsS http://localhost:9090/api/v1/rules | grep -q 'infrastructure-alerts'"

check "Recording rules loaded" \
    "curl -fsS http://localhost:9090/api/v1/rules | grep -q 'infrastructure-recording-rules'"

echo
echo "Alertmanager"
echo "----------------------------------------------"

check "Prometheus → Alertmanager connection" \
    "curl -fsS http://localhost:9090/api/v1/alertmanagers | grep -q 'alertmanager:9093'"

echo
echo "=============================================="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "=============================================="

if [ "$FAIL" -eq 0 ]; then
    echo
    echo "Monitoring stack is healthy."
    exit 0
else
    echo
    echo "Monitoring stack has one or more failures."
    exit 1
fi