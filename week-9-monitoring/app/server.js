// store-api — the app the Week 9 lab watches.
//
// It does three things that make it observable, exactly as the session describes:
//   1. Exposes a /metrics page (traffic, errors, latency) — Prometheus scrapes it.
//   2. Logs every event as structured JSON on stdout — Promtail ships it to Loki.
//   3. Has an /admin/fail knob so you can CREATE an incident on demand for the demo.
//
// Nothing here is production code — it exists to make graphs move and logs fill.

const os = require('os')
const express = require('express')
const client = require('prom-client')
const pino = require('pino')

const app = express()

// pino logs JSON to stdout by default — that is the whole point.
//  - base.instance = the container's hostname, so every line says WHICH replica
//    produced it (the "which one handled the failing request?" story).
//  - the level formatter emits level as a WORD ("error") not a number (50), so
//    LogQL queries like  {app="store-api"} | json | level="error"  work.
const log = pino({
  base: { instance: os.hostname() },
  formatters: { level: (label) => ({ level: label }) },
})

// ---------------------------------------------------------------------------
// METRICS (Step 2 of the monitoring session)
// ---------------------------------------------------------------------------
const register = new client.Registry()
client.collectDefaultMetrics({ register }) // free: process CPU, heap, event-loop lag

const httpRequests = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
})

const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Request latency in seconds',
  labelNames: ['method', 'route'],
  buckets: [0.05, 0.1, 0.3, 0.5, 1, 2, 5],
  registers: [register],
})

// Record one count + one timing for every request, and log it.
app.use((req, res, next) => {
  const end = httpDuration.startTimer({ method: req.method })
  res.on('finish', () => {
    const route = req.route ? req.route.path : 'unmatched'
    httpRequests.inc({ method: req.method, route, status: res.statusCode })
    end({ route })
    const line = { method: req.method, route, status: res.statusCode }
    if (res.statusCode >= 500) log.error(line, 'request failed')
    else log.info(line, 'request handled')
  })
  next()
})

// ---------------------------------------------------------------------------
// THE INCIDENT KNOB
// failRate is the fraction of /api/orders that fail. Normally 2% — realistic.
// Turn it up with /admin/fail?rate=0.5 to stage an outage during the demo,
// then /admin/fail?rate=0 to "roll back" and watch the graphs recover.
// ---------------------------------------------------------------------------
let failRate = 0.02

// ---------------------------------------------------------------------------
// ROUTES
// ---------------------------------------------------------------------------
app.get('/', (_req, res) => {
  res.send('<h1>store-api</h1><p>try /api/products and /api/orders</p>')
})

app.get('/health', (_req, res) => res.json({ status: 'ok' }))

// Fast, always succeeds
app.get('/api/products', (_req, res) => {
  setTimeout(() => res.json({ products: ['book', 'mug', 'sticker'] }), 20)
})

// The interesting one: does real-ish work and fails at the current failRate.
app.get('/api/orders', (req, res) => {
  const work = 40 + Math.random() * 120 // 40–160ms of "work"
  setTimeout(() => {
    if (Math.random() < failRate) {
      // A realistic failure: the payments dependency is unreachable.
      log.error(
        { user_id: 1000 + Math.floor(Math.random() * 9000), upstream: 'payments:5432' },
        'payment failed: connection refused',
      )
      return res.status(500).json({ error: 'payment failed' })
    }
    res.json({ order_id: Math.random().toString(36).slice(2, 8), status: 'placed' })
  }, work)
})

// Stage / resolve an incident on demand.
app.get('/admin/fail', (req, res) => {
  const rate = Math.max(0, Math.min(1, parseFloat(req.query.rate)))
  if (Number.isNaN(rate)) return res.status(400).json({ error: 'pass ?rate=0..1' })
  failRate = rate
  log.warn({ failRate }, 'fail rate changed')
  res.json({ failRate })
})

// The scrape endpoint Prometheus reads every 15s.
app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', register.contentType)
  res.end(await register.metrics())
})

const PORT = process.env.PORT || 3000
app.listen(PORT, () => log.info({ port: PORT }, 'store-api started'))
