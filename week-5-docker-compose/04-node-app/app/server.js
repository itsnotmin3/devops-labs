const express = require('express')
const os = require('os')

const app = express()
const PORT = process.env.PORT || 3000
const GREETING = process.env.GREETING || 'Hello'

app.get('/', (req, res) => {
  res.send(`<!doctype html>
<html><head><meta charset="utf-8"><title>Compose Node App</title>
<style>body{font-family:system-ui,sans-serif;display:grid;place-items:center;height:100vh;margin:0;background:#0f172a;color:#e2e8f0}
.card{background:#1e293b;border:1px solid #334155;border-radius:16px;padding:32px 44px;text-align:center}
h1{color:#38bdf8}</style></head>
<body><div class="card">
  <h1>${GREETING}</h1>
  <p>This Node app was <strong>built and run by Docker Compose</strong>.</p>
  <p>container: ${os.hostname()} · try <code>/api</code></p>
</div></body></html>`)
})

app.get('/api', (req, res) =>
  res.json({ greeting: GREETING, host: os.hostname(), time: new Date().toISOString() }),
)
app.get('/health', (req, res) => res.send('OK'))

app.listen(PORT, () => console.log(`api listening on ${PORT}`))
