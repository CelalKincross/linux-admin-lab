# HPC Extension — Day 2: Monitoring & Observability

**Date**: 2026-01-19
**Objective**: Add lightweight monitoring to observe node health, resource usage, and failures proactively.

## Phase 2 Architecture

```
┌─────────────────┐         ┌─────────────────┐
│   lab-admin     │ scrapes │   lab-compute   │
│                 │◄────────│                 │
│  Prometheus     │  :9100  │  node_exporter  │
│  Grafana        │         │                 │
│  Alert rules    │         │                 │
└─────────────────┘         └─────────────────┘
```

| Component | Location | Role |
|-----------|----------|------|
| Node Exporter | lab-compute | **The Sensor** — scrapes hardware metrics from OS |
| Prometheus | lab-admin | **The Brain** — time-series database, evaluates alert rules |
| Grafana | lab-admin | **The Eyes** — visualization layer for admin dashboards |

---

## Phase 2.1 — Node Exporter (lab-compute) ✅

### Installation

```bash
# Create service user
sudo useradd --no-create-home --shell /usr/sbin/nologin node_exporter

# Download and install
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-arm64.tar.gz
tar xzf node_exporter-*.tar.gz
sudo cp node_exporter-*/node_exporter /usr/local/bin/
```

### Systemd Service

```ini
# /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
```

### Verification

```bash
curl http://localhost:9100/metrics | head
```

---

## Phase 2.2 — Prometheus (lab-admin) ✅

### Installation

```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-arm64.tar.gz
tar xzf prometheus-*.tar.gz
sudo cp prometheus-*/prometheus /usr/local/bin/
sudo cp prometheus-*/promtool /usr/local/bin/
sudo mkdir -p /etc/prometheus /var/lib/prometheus
```

### Configuration

```yaml
# /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

rule_files:
  - "alerts.yml"

scrape_configs:
  - job_name: "lab-compute"
    static_configs:
      - targets: ["lab-compute:9100"]
```

### Systemd Service

```ini
# /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus
```

### Verification

```bash
curl http://localhost:9090/-/healthy
```

---

## Phase 2.3 — Grafana (lab-admin) ✅

### Installation

```bash
sudo apt update
sudo apt install -y grafana
sudo systemctl enable --now grafana-server
```

### Access

- URL: `http://lab-admin:3000`
- Default credentials: `admin / admin`

### Dashboard Setup

1. Add Prometheus data source (`http://localhost:9090`)
2. Import "Node Exporter Full" dashboard (ID: 1860)
3. Customize to show only essential "Core Four" panels:

| Metric | Why It Matters |
|--------|----------------|
| **CPU Busy** | Identifies hung or overloaded Slurm jobs |
| **RAM Used** | Monitors for memory leaks or OOM risks |
| **Disk Usage** | Ensures root filesystem doesn't fill with logs |
| **Uptime** | Tracks node stability and unexpected reboots |

Dashboard named: **HPC Cluster Health – Admin View**

**Design philosophy:** High-signal, low-noise. Removed unnecessary panels to focus on actionable metrics.

---

## Phase 2.4 — Alert Rules ✅

### NodeDown Alert

```yaml
# /etc/prometheus/alerts.yml
groups:
- name: node-alerts
  rules:
  - alert: NodeDown
    expr: up{job="lab-compute"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      description: "Node {{ $labels.instance }} is unreachable"
```

**Why `for: 1m`?**
- Prevents **alert fatigue** — waits 60 seconds to confirm the node is actually down
- Avoids false positives from brief network blips or scrape timeouts
- Only fires critical alarm when node is confirmed unreachable

### Alert Validation

Tested by stopping `node_exporter` on lab-compute:

```bash
# On lab-compute
sudo systemctl stop node_exporter

# Wait 1 minute, check Prometheus alerts page
# Alert transitions: Inactive → Pending → FIRING
```

**Result:** Alert fired correctly, proving proactive failure detection.

---

## Key Takeaways

1. **Prometheus pull model** — Centralized scraping simplifies firewall rules (only controller needs outbound)

2. **Node Exporter is lightweight** — Minimal resource impact, standard metrics format

3. **One alert is enough** — `NodeDown` demonstrates operational alerting without over-engineering

4. **Dashboard restraint** — Imported standard dashboard, removed unnecessary panels (shows maturity)

---

## Interview Talking Points

> "I implemented node-level monitoring to observe cluster health and resource usage."

> "I focused on actionable metrics and basic alerting rather than overbuilding dashboards."

> "This helps operators detect node failures before users submit jobs."

---

## Phase 2 Complete ✅

| Component | Location | Purpose |
|-----------|----------|---------|
| node_exporter | lab-compute:9100 | Host metrics |
| Prometheus | lab-admin:9090 | Metrics collection + alerting |
| Grafana | lab-admin:3000 | Visualization |
