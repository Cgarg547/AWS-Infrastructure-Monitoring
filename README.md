# AWS Infrastructure Monitoring

A production-style infrastructure monitoring stack built with **Prometheus, Grafana, Alertmanager, Node Exporter, Docker Compose, Terraform, and GitHub Actions**.

The project provides real-time infrastructure metrics, dashboards, alerting, recording rules, automated health checks, and CI-based configuration validation.

> **Current deployment:** The monitoring stack runs locally using Docker Compose. Terraform configuration for AWS infrastructure is included and validated, but AWS deployment is intentionally not performed in this version.

---

## 🚀 Features

- Real-time infrastructure monitoring with Prometheus
- System metrics collected using Node Exporter
- Grafana monitoring dashboard
- Alertmanager integration
- Critical and warning alert routing
- CPU, memory, disk, and network monitoring
- Prometheus recording rules
- Infrastructure health/status panels
- Automated monitoring health-check script
- Docker Compose deployment
- Terraform infrastructure configuration
- GitHub Actions CI validation
- Prometheus configuration and rule validation
- Grafana dashboard JSON validation
- Shell-script syntax validation

---

## 🏗️ Architecture

```text
                    ┌──────────────────────┐
                    │      Grafana         │
                    │   Visualization      │
                    │      :3000           │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │     Prometheus       │
                    │   Metrics + Rules    │
                    │      :9090           │
                    └──────┬─────────┬─────┘
                           │         │
                ┌──────────┘         └──────────────┐
                ▼                                   ▼
       ┌──────────────────┐              ┌──────────────────┐
       │  Node Exporter   │              │   Alertmanager   │
       │     :9100        │              │      :9093       │
       │ System Metrics   │              │ Alert Routing    │
       └──────────────────┘              └──────────────────┘
```

### Data Flow

```text
Node Exporter
      │
      │ metrics
      ▼
Prometheus
      │
      ├── Recording Rules
      │
      ├── Alert Rules
      │
      ▼
Alertmanager
      │
      │ alerts
      ▼
Grafana
      │
      ▼
Monitoring Dashboard
```

---

## 🛠️ Technologies

| Technology | Purpose |
|---|---|
| Prometheus | Metrics collection and alert evaluation |
| Node Exporter | Host/system metrics |
| Grafana | Metrics visualization |
| Alertmanager | Alert routing and management |
| Docker | Containerized services |
| Docker Compose | Local monitoring stack orchestration |
| Terraform | Infrastructure-as-Code for AWS |
| GitHub Actions | CI/CD configuration validation |
| Bash | Automation and health checks |
| YAML | Monitoring configuration |

---

## 📁 Project Structure

```text
AWS/
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── alertmanager/
│   └── alertmanager.yml
│
├── docker/
│   ├── docker-compose.yml
│   └── prometheus/
│       └── prometheus.yml
│
├── grafana/
│   ├── dashboards/
│   │   └── aws-monitoring.json
│   │
│   └── provisioning/
│       ├── dashboards/
│       │   └── dashboard.yml
│       │
│       └── datasources/
│           └── prometheus.yml
│
├── node-exporter/
│   ├── install-node-exporter.sh
│   ├── node-exporter.service
│   └── node_exporter.sh
│
├── prometheus/
│   ├── alerts.yml
│   ├── prometheus.yml
│   ├── prometheus_ec2.yml
│   ├── prometheus_relabeling.yml
│   ├── prometheus_service_discovery.yml
│   └── recording_rules.yml
│
├── scripts/
│   ├── health-check.sh
│   └── install-monitoring.sh
│
├── terraform/
│   ├── .terraform.lock.hcl
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── ec2.tf
│   ├── iam.tf
│   └── security-groups.tf
│
├── .gitignore
├── .yamllint.yml
├── LICENSE
└── README.md
```

---

# 🐳 Running the Monitoring Stack

## Prerequisites

Install:

- Docker Desktop
- Docker Compose
- Git

Verify Docker:

```bash
docker --version
docker compose version
```

---

## Start the Stack

From the project root:

```bash
docker compose -f docker/docker-compose.yml up -d
```

Check the containers:

```bash
docker ps
```

Expected services:

```text
prometheus
alertmanager
grafana
node-exporter
```

---

## Stop the Stack

```bash
docker compose -f docker/docker-compose.yml down
```

To stop the stack while preserving persistent volumes:

```bash
docker compose -f docker/docker-compose.yml down
```

---

# 📊 Grafana

Open:

```text
http://localhost:3000
```

The provisioned dashboard is:

**AWS Infrastructure Monitoring**

The dashboard contains:

### Infrastructure Status

- Node Exporter Status
- Prometheus Status
- Active Alerts

### System Metrics

- CPU Usage
- Memory Usage
- Disk Usage
- Network Traffic
- System Load
- System Uptime

The dashboard automatically uses Prometheus as its data source.

---

# 🔎 Prometheus

Open:

```text
http://localhost:9090
```

### Targets

Go to:

```text
Status → Targets
```

The monitoring stack contains:

```text
prometheus:9090
node-exporter:9100
```

Both should report:

```text
UP
```

---

# 🚨 Alerting

Prometheus evaluates infrastructure alert rules defined in:

```text
prometheus/alerts.yml
```

Current alerts include:

| Alert | Condition | Severity |
|---|---|---|
| InstanceDown | Node Exporter unavailable | Critical |
| PrometheusDown | Prometheus unavailable | Critical |
| HighCPUUsage | CPU above 80% for 5 minutes | Warning |
| HighMemoryUsage | Memory above 80% for 5 minutes | Warning |
| HighDiskUsage | Disk above 85% for 5 minutes | Warning |

---

## Alertmanager

Alertmanager is available at:

```text
http://localhost:9093
```

Alerts are routed according to severity:

```text
critical → critical receiver
warning  → warning receiver
```

The current configuration provides the routing structure and can be extended with notification integrations such as email, Slack, or other supported receivers.

---

# 📈 Recording Rules

Recording rules are stored in:

```text
prometheus/recording_rules.yml
```

The project calculates:

```text
instance:cpu_usage_percent
instance:memory_usage_percent
instance:disk_usage_percent
instance:network_receive_bytes_per_second
instance:network_transmit_bytes_per_second
```

These precomputed metrics make dashboard queries simpler and reduce repeated PromQL calculations.

---

# 🩺 Health Check

The project includes an automated health-check script:

```bash
./scripts/health-check.sh
```

The script verifies:

- Prometheus container
- Alertmanager container
- Grafana container
- Node Exporter container
- Prometheus readiness
- Alertmanager readiness
- Grafana health
- Node Exporter metrics
- Prometheus target status
- Alert rules
- Recording rules
- Recording-rule queries
- Prometheus → Alertmanager connectivity

A healthy environment should report:

```text
Passed: 16
Failed: 0

✓ Monitoring stack is healthy.
```

---

# 🧪 Alert Testing

The `InstanceDown` alert can be tested locally.

Stop Node Exporter:

```bash
docker stop node-exporter
```

Wait approximately 1–2 minutes.

Check Prometheus:

```text
http://localhost:9090/alerts
```

The `InstanceDown` alert should eventually become:

```text
Firing
```

with:

```text
severity="critical"
```

Alertmanager can be checked at:

```text
http://localhost:9093
```

Grafana should also show the Node Exporter status as:

```text
DOWN
```

and the active alert count should increase.

Restore Node Exporter:

```bash
docker start node-exporter
```

After the metrics recover, the alert should resolve and Grafana should return to:

```text
Node Exporter: UP
Active Alerts: 0
```

---

# ⚙️ GitHub Actions CI

The project uses GitHub Actions to automatically validate monitoring configuration.

Workflow:

```text
.github/workflows/ci.yml
```

The CI pipeline validates:

### YAML

```text
yamllint
```

### Prometheus

```text
promtool check config
promtool check rules
```

### Docker Compose

```text
docker compose config
```

### Shell Scripts

```text
bash -n
```

### Grafana

```text
python -m json.tool
```

### Terraform

```text
terraform fmt -check
terraform init -backend=false
terraform validate
```

Every push to `main` and pull request targeting `main` triggers the workflow.

---

# 🏗️ Terraform

Terraform configuration is located in:

```text
terraform/
```

The configuration includes infrastructure definitions for:

- EC2
- IAM
- Security Groups
- Variables
- Outputs

Terraform configuration can be validated locally:

```bash
cd terraform

terraform fmt -check
terraform init -backend=false
terraform validate

cd ..
```

### AWS Deployment Status

The Terraform configuration is included as infrastructure-as-code for future AWS deployment.

The current version of this project focuses on the **local monitoring stack**, so AWS infrastructure is not automatically deployed.

This allows the monitoring architecture, configuration, dashboards, alerts, and CI pipeline to be developed and validated without requiring live AWS infrastructure.

---

# 🔐 Security

The project intentionally excludes sensitive configuration from Git.

The `.gitignore` includes:

```text
.env
.env.*
*.tfvars
*.tfvars.json
*.tfstate
*.tfstate.*
.terraform/
```

AWS credentials and secrets should never be committed to the repository.

For AWS deployment, use appropriate AWS authentication mechanisms and provide sensitive values through environment variables, secret management, or CI/CD secrets.

---

# 🔄 Useful Commands

### Start monitoring

```bash
docker compose -f docker/docker-compose.yml up -d
```

### View running containers

```bash
docker ps
```

### View logs

```bash
docker compose -f docker/docker-compose.yml logs
```

### Prometheus logs

```bash
docker logs prometheus
```

### Grafana logs

```bash
docker logs grafana
```

### Alertmanager logs

```bash
docker logs alertmanager
```

### Node Exporter logs

```bash
docker logs node-exporter
```

### Run health check

```bash
./scripts/health-check.sh
```

### Stop monitoring

```bash
docker compose -f docker/docker-compose.yml down
```

---

# 🧪 Validation Summary

The project has been validated locally with:

```text
Prometheus configuration       ✓
Prometheus alert rules         ✓
Prometheus recording rules     ✓
Docker Compose                 ✓
Terraform                      ✓
Shell scripts                  ✓
Grafana dashboard JSON         ✓
YAML linting                   ✓
Monitoring health checks       ✓
GitHub Actions CI              ✓
```

The monitoring health check currently verifies:

```text
16 checks passed
0 checks failed
```

---

# 📸 Monitoring Dashboard

The Grafana dashboard provides a centralized view of infrastructure health and performance.

Key indicators include:

```text
Node Exporter Status
Prometheus Status
Active Alerts
CPU Usage
Memory Usage
Disk Usage
Network Traffic
System Load
System Uptime
```

---

# 🎯 Project Goals

This project demonstrates practical experience with:

- Infrastructure monitoring
- Observability
- Prometheus
- Grafana
- Alertmanager
- Docker
- Infrastructure-as-Code
- Terraform
- CI/CD
- Linux system monitoring
- PromQL
- Configuration validation
- Monitoring automation

---

# 🔮 Future Improvements

Potential future enhancements include:

- AWS EC2 service discovery
- CloudWatch integration
- Real AWS infrastructure deployment
- Remote Alertmanager notifications
- Slack/email alert integration
- HTTPS/TLS
- Authentication improvements
- Persistent remote Prometheus storage
- Additional infrastructure dashboards
- Kubernetes monitoring
- Automated deployment through CI/CD

---

# 📄 License

This project is licensed under the terms specified in the repository's `LICENSE` file.

---

## 👤 Author

**Chirag Garg**

GitHub:

https://github.com/Cgarg547

---

⭐ If you find this project useful, consider giving the repository a star.