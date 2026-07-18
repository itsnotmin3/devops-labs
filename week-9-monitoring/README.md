# Week 9 — Monitoring & Observability lab

The same story as Sessions 27 and 28, live: a small **app** goes from black box
to fully monitored, and you stage a real incident on demand.

```
                     store-api  (exposes /metrics, logs JSON to stdout)
                        │  ▲
             scrape ────┘  └──── docker logs
                 ▼                    ▼
  node-exporter ─► Prometheus     Promtail ─► Loki
                        └──────┬──────────────┘
                               ▼
                            Grafana   (one dashboard: metrics + logs)
```

```
week-9-monitoring/
├── app/                     the instrumented demo app (Node + prom-client + pino)
├── load.sh                  generates traffic so the graphs move
├── compose.yaml             the whole stack, app included
├── prometheus/              scrape config (host + the app)
├── promtail/                ships the app's container logs to Loki
└── grafana/provisioning/    datasources + a ready-made dashboard, pre-wired
```

---

## Run the whole thing

```bash
cd week-9-monitoring
docker compose up -d --build        # --build compiles the app image
docker compose ps                   # everything should be "Up"
```

| What | Where | Login |
|------|-------|-------|
| The app | http://SERVER_IP:8080 | — |
| Grafana | http://SERVER_IP:3000 | `admin` / `admin` |
| Prometheus | http://SERVER_IP:9090 | — |

Datasources **and** a dashboard are already provisioned — no clicking to set up.

Now start traffic in its own terminal and leave it running:

```bash
chmod +x load.sh
./load.sh                            # or: ./load.sh http://SERVER_IP:8080
```

---

## The live demo — follow the session, step by step

### Step 2 — the app exposes its numbers
```bash
curl -s localhost:8080/metrics | grep http_requests_total
```
You will see one line per method/route/status — the app counting itself.

### Step 3 — Prometheus is collecting them
Prometheus → **Status → Targets**: `prometheus`, `node` and **`store-api`** are all **UP**.
Then **Graph**, and watch these move as `load.sh` runs:
```promql
sum(rate(http_requests_total[1m]))                                  # traffic (req/s)
sum by (status) (rate(http_requests_total[1m]))                     # split by status
sum(rate(http_requests_total{status=~"5.."}[1m]))
  / sum(rate(http_requests_total[1m]))                              # error ratio
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))  # p95
```

### Step 5 — see it on the dashboard
Grafana → **Dashboards → "Store — golden signals"**. It is already built:
traffic, error rate, p95 latency on top; requests-by-status and latency trends;
and a **live logs panel** at the bottom straight from the app.

### Step 4 (logs) — search them in Explore
Grafana → **Explore** → **Loki**:
```logql
{app="store-api"}                          # every line from the app
{app="store-api"} | json | level="error"   # only errors, parsed as JSON
{app="store-api"} |= "payment failed"      # the failing checkouts
sum(rate({app="store-api"} | json | level="error" [1m]))   # errors/sec, from logs
```

---

## Step 6 — stage an incident (the payoff)

This is the part to perform. Everything is calm at ~2% errors. Now break it:

```bash
# crank the checkout failure rate to 40%
curl "localhost:8080/admin/fail?rate=0.4"
```

Watch, in order:
1. On the **dashboard**, the **Error rate %** tile jumps and turns **red**; latency stays flat → *failing, not slow*.
2. In **Explore**, `{app="store-api"} | json | level="error"` fills with
   `payment failed: connection refused ... payments:5432`.
3. You have your root cause from the log line — the payments dependency.

Then "roll back" and watch it heal:

```bash
curl "localhost:8080/admin/fail?rate=0"      # back to healthy
```

The error tile falls back to green within a minute. Same shape as the 3am
incident in the session — pager, dashboard, logs, fix — in about two minutes.

---

## Add an alert (optional, Grafana UI)

Grafana → **Alerting → Alert rules → New**:
- Query (Prometheus): `100 * sum(rate(http_requests_total{status=~"5.."}[1m])) / sum(rate(http_requests_total[1m]))`
- Condition: **IS ABOVE 5** for **1m**
- Add a contact point (email/webhook) and save.

Now `curl "localhost:8080/admin/fail?rate=0.4"` and the alert fires; set it back
to 0 and it clears.

---

## Bonus — the host dashboard (node-exporter)

Grafana → **Dashboards → New → Import** → ID **1860** ("Node Exporter Full") →
pick **Prometheus** → Import. A full CPU/memory/disk/network dashboard for the
machine, free.

---

## Cleanup

```bash
docker compose down          # stop (keeps metrics, logs, dashboards)
docker compose down -v       # also wipe the volumes
```

> `admin/admin` is a demo credential for a local lab. For anything real, set a
> strong `GF_SECURITY_ADMIN_PASSWORD` from a `.env` file and never expose
> Grafana/Prometheus/the app publicly without auth.
