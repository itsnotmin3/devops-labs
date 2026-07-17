# Week 9 — Monitoring & Observability lab

A complete local observability stack in one `docker compose up`:

```
          ┌─ node-exporter ─┐  metrics
          │                 ▼
  host ───┤            Prometheus ──┐
          │                          ├──► Grafana  (dashboards)
          └─ /var/log ─► Promtail ─► Loki ──┘        (logs)
```

```
week-9-monitoring/
├── compose.yaml
├── prometheus/prometheus.yml            # scrape config
├── promtail/promtail-config.yml         # which logs to ship
└── grafana/provisioning/datasources/    # Prometheus + Loki pre-wired
```

## Run it
```bash
cd week-9-monitoring
docker compose up -d
docker compose ps
```
- **Grafana** → http://SERVER_IP:3000 — login `admin` / `admin`
- **Prometheus** → http://SERVER_IP:9090

Both datasources are already configured — no clicking required.

---

## Lab 1 — Prometheus targets & PromQL
Open Prometheus → **Status → Targets**: `prometheus` and `node` should be **UP**.

Then go to **Graph** and try these queries:
```promql
up                                        # 1 = target healthy, 0 = down
node_memory_MemAvailable_bytes            # free memory
rate(node_cpu_seconds_total{mode="idle"}[5m])   # idle CPU per core
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)  # CPU % used
node_filesystem_avail_bytes{mountpoint="/"}     # free disk on /
```

## Lab 2 — Grafana dashboard
1. Grafana → **Dashboards → New → Import**
2. Enter dashboard ID **1860** ("Node Exporter Full"), click Load
3. Pick the **Prometheus** datasource → Import

You now have a full host dashboard — CPU, memory, disk, network — for free.

## Lab 3 — Logs with Loki (LogQL)
Grafana → **Explore** → pick the **Loki** datasource, then query:
```logql
{job="varlogs"}                       # all shipped logs
{job="varlogs"} |= "error"            # only lines containing "error"
{job="varlogs"} |= "ssh"              # auth activity
count_over_time({job="varlogs"}[5m])  # log volume over time
```
Generate some logs to see it move:
```bash
logger "hello from the bootcamp lab"      # writes to /var/log/syslog
logger "ERROR something broke"
```

## Lab 4 — Metrics AND logs together
In one Grafana dashboard add two panels:
- a **Prometheus** panel: CPU % used
- a **Loki** panel: `{job="varlogs"} |= "error"`

That is the whole point of observability: the graph tells you **that** something
broke, the logs tell you **why** — on one screen.

## Lab 5 — An alert
Grafana → **Alerting → Alert rules → New**:
- Query: `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
- Condition: `IS ABOVE 80` for `5m`
- Add a contact point (email/webhook) and save.

Stress the box to trigger it:
```bash
sudo apt install -y stress-ng
stress-ng --cpu 4 --timeout 300s
```

---

## Cleanup
```bash
docker compose down          # stop (keeps dashboards + metrics)
docker compose down -v       # also wipe the volumes
```

> Note: `admin/admin` is a demo credential for a local lab. For anything real,
> set a strong `GF_SECURITY_ADMIN_PASSWORD` from a `.env` file and never expose
> Grafana/Prometheus publicly without auth.
