# 📊 monitoring-stack

> Production-ready observability stack with Prometheus, Grafana, Alertmanager and Node Exporter — fully configured with Docker Compose, pre-built dashboards and alert rules.

![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat-square&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat-square&logo=grafana&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)
![Alertmanager](https://img.shields.io/badge/Alertmanager-E6522C?style=flat-square&logo=prometheus&logoColor=white)

---

## 🏗️ Stack

| Service | Port | Description |
|---------|------|-------------|
| Prometheus | 9090 | Metrics collection and storage |
| Grafana | 3000 | Dashboards and visualisation |
| Alertmanager | 9093 | Alert routing and notifications |
| Node Exporter | 9100 | Host system metrics (CPU, mem, disk) |
| cAdvisor | 8080 | Container resource metrics |

## 🚀 Quick Start

```bash
# Clone
git clone https://github.com/hugpaim/monitoring-stack.git
cd monitoring-stack

# Start full stack
make up

# Check all services are healthy
make health

# Access dashboards
#   Grafana:      http://localhost:3000  (admin / admin)
#   Prometheus:   http://localhost:9090
#   Alertmanager: http://localhost:9093
```

## 📁 Structure

```
monitoring-stack/
├── docker-compose.yml          # Full stack definition
├── Makefile                    # Convenience commands
├── prometheus/
│   ├── prometheus.yml          # Scrape configs and rules ref
│   ├── rules/
│   │   └── host.rules.yml      # Host-level alert rules
│   └── alerts/
│       └── app.rules.yml       # Application alert rules
├── alertmanager/
│   └── alertmanager.yml        # Routing and receivers
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/        # Auto-configure Prometheus datasource
│   │   └── dashboards/         # Auto-load dashboards
│   └── dashboards/
│       ├── host.json           # Node Exporter dashboard
│       └── containers.json     # cAdvisor containers dashboard
├── exporters/
│   └── docker-compose.exporters.yml  # Optional extra exporters
└── scripts/
    ├── setup.sh                # One-command setup
    └── test-alert.sh           # Fire a test alert
```

## ⚙️ Configuration

### Alertmanager — Slack notifications
Edit `alertmanager/alertmanager.yml` and set your webhook URL:
```yaml
slack_configs:
  - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
```

### Add a new scrape target
Edit `prometheus/prometheus.yml`:
```yaml
- job_name: 'my-app'
  static_configs:
    - targets: ['my-app:8080']
```
Then `make reload` to apply without restarting.

## 📊 Pre-built Dashboards

| Dashboard | Description |
|-----------|-------------|
| Host Overview | CPU, memory, disk, network per host |
| Containers | CPU, memory, net I/O per container |

---

> Part of [@hugpaim](https://github.com/hugpaim) DevOps portfolio
