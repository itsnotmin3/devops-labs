const express = require('express')
const os = require('os')

const app = express()
const PORT = process.env.PORT || 3000

app.get('/', (req, res) => {
  res.send(`<!doctype html>
<html><head><meta charset="utf-8"><title>Dockerized Node API</title>
<style>
  body{font-family:system-ui,sans-serif;display:grid;place-items:center;height:100vh;margin:0;background:#0f172a;color:#e2e8f0}
  .card{background:#1e293b;border:1px solid #334155;border-radius:16px;padding:36px 48px;text-align:center}
  h1{color:#38bdf8;margin:.2em 0}
  code{background:#0f172a;padding:2px 7px;border-radius:6px;color:#7dd3fc}
</style></head>
<body><div class="card">
  <h1>🐳 Dockerized Node API</h1>
  <p>This Express app is running inside a container.</p>
  <p>container host: <code>${os.hostname()}</code></p>
  <p>try <code>/api</code> and <code>/health</code></p>
</div></body></html>`)
})

app.get('/health', (req, res) => res.send('OK'))

app.get('/api', (req, res) => {
  res.json({ message: 'Hello from inside the container', host: os.hostname(), time: new Date().toISOString() })
})

app.listen(PORT, () => console.log(`node-api listening on http://0.0.0.0:${PORT}`))
