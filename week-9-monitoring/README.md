# Week 9 — Monitoring & Logging lab

Sessions 27 and 28, live. One small **app** (`store-api`) runs inside a full
observability stack, and you walk both flows — metrics and logs — end to end,
staging a real incident on demand.

```
                     store-api  (exposes /metrics, logs JSON to stdout)
                        │  ▲
             scrape ────┘  └──── docker logs
                 ▼                    ▼
  node-exporter ─► Prometheus     Promtail ─► Loki
                        └──────┬──────────────┘
                               ▼
                            Grafana   (two dashboards: golden signals + logs)
```

```
week-9-monitoring/
├── app/                     instrumented demo app (Node + prom-client + pino)
├── load.sh                  generates traffic so graphs and logs move
├── compose.yaml             the whole stack, app included
├── prometheus/              scrape config (host + the app)
├── promtail/                ships the app's container logs to Loki
└── grafana/provisioning/    datasources + two dashboards, pre-wired
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

Both datasources **and** both dashboards are provisioned — nothing to set up.

Start traffic in its own terminal and leave it running:

```bash
chmod +x load.sh
./load.sh                            # or: ./load.sh http://SERVER_IP:8080
```

---

# Session 27 — Monitoring

### Step 2 — the app exposes its numbers
```bash
curl -s localhost:8080/metrics | grep http_requests_total
```
One line per method/route/status — the app counting itself.

### Step 3 — Prometheus is collecting them
Prometheus → **Status → Targets**: `prometheus`, `node` and **`store-api`** are **UP**.
Then **Graph**, and watch these move while `load.sh` runs:
```promql
sum(rate(http_requests_total[1m]))                                  # traffic
sum by (status) (rate(http_requests_total[1m]))                     # by status
sum(rate(http_requests_total{status=~"5.."}[1m]))
  / sum(rate(http_requests_total[1m]))                              # error ratio
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))  # p95
```

### Step 5 — see it on the dashboard
Grafana → **Dashboards → "Store — golden signals"**. Already built: traffic,
error rate, p95 latency on top; requests-by-status and latency trends; and a
live logs panel at the bottom.

### Bonus — the host dashboard
Grafana → **Dashboards → New → Import** → ID **1860** ("Node Exporter Full") →
pick **Prometheus** → Import. A full CPU/memory/disk/network dashboard, free.

---

# Session 28 — Logging

### Step 1 — see the structured logs at the source
```bash
docker compose logs --tail 5 app
```
Every line is JSON, with an `instance` (which container produced it), a `level`,
a constant `msg`, and fields:
```json
{"level":"info","instance":"3f5c9d1e7b2a","method":"GET","route":"/api/orders","status":200,"msg":"request handled"}
{"level":"error","instance":"3f5c9d1e7b2a","user_id":4821,"upstream":"payments:5432","msg":"payment failed: connection refused"}
```
That is the whole point of structured logging: `user_id` is a **field**, not a
word buried in a sentence — so you can filter on it exactly.

### Step 2 — everything in one place (centralized)
Grafana → **Explore** → **Loki**. First, see logs from *every* container at once:
```logql
{env="demo"}                               # app + grafana + prometheus + loki…
```
That is centralized logging: no matter how many containers (or replicas, or
servers) you run, the logs arrive in one place and you never SSH anywhere. Now
narrow to the app:
```logql
{app="store-api"}
```

### Step 3 — LogQL, built up
```logql
{app="store-api"}                          # every line from the app
{app="store-api"} |= "payment failed"      # lines CONTAINING this text
{app="store-api"} | json | level="error"   # parse JSON, filter on a field
{app="store-api"} | json | status="500"    # only failed requests
{app="store-api"} | json | user_id="4821"  # one specific customer's trouble
```
Turn logs into graphs (the same grammar as PromQL from Session 27):
```logql
sum by (level) (rate({app="store-api"} | json [1m]))                     # volume by level
sum by (instance) (count_over_time({app="store-api"} | json | level="error" [5m]))  # errors per replica
```

### Step 4 — the logs dashboard
Grafana → **Dashboards → "Store — logs (Loki)"**: log volume by level, an
errors-per-second tile, a live error stream, and all app logs — one screen.

---

## The incident (both sessions meet here)

Everything is calm at ~2% errors. Now break it:

```bash
curl "localhost:8080/admin/fail?rate=0.4"     # 40% of checkouts now fail
```

Watch, in order:
1. **Golden-signals dashboard** — the **Error rate %** tile jumps and turns **red**; latency stays flat → *failing, not slow*.
2. **Logs dashboard / Explore** — `{app="store-api"} | json | level="error"` fills with
   `payment failed: connection refused ... payments:5432`, each line carrying the `instance` and `user_id`.
3. **Root cause from the log line**: the payments dependency is unreachable — the *why* the metric could never show.

Then "roll back" and watch both heal:

```bash
curl "localhost:8080/admin/fail?rate=0"       # back to healthy
```

Metrics find the problem and prove it is real; the log line explains it. Same
shape as the 3am incident in the sessions — pager, dashboard, logs, fix — in
about two minutes.

> **Add an alert (optional):** Grafana → Alerting → Alert rules → New. Query
> `100 * sum(rate(http_requests_total{status=~"5.."}[1m])) / sum(rate(http_requests_total[1m]))`,
> condition **IS ABOVE 5** for **1m**, add a contact point. Crank the fail rate
> and it fires; set it back to 0 and it clears.

---

## Cleanup

```bash
docker compose down          # stop (keeps metrics, logs, dashboards)
docker compose down -v       # also wipe the volumes
```

> `admin/admin` is a demo credential for a local lab. For anything real, set a
> strong `GF_SECURITY_ADMIN_PASSWORD` from a `.env` file and never expose
> Grafana / Prometheus / the app publicly without auth.
