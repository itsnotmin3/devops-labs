// Tiny demo backend for the NGINX session — ZERO dependencies.
// Run with:  node app.js
// Configure via env vars:
//   PORT  (default 3000)   NAME (default "Backend")   COLOR (default "#2563eb")
//
// Run ONE copy on 3000 for the reverse-proxy demo, or THREE copies on
// 3001/3002/3003 (different NAME/COLOR) for the load-balancing demo — each
// page shows its own port/colour, so you SEE NGINX alternate on refresh.

const http = require('http')
const os = require('os')

const PORT = process.env.PORT || 3000
const NAME = process.env.NAME || 'Backend'
const COLOR = process.env.COLOR || '#2563eb'
const HOST = os.hostname()

let hits = 0

const server = http.createServer((req, res) => {
  // Health check (handy for NGINX upstreams / load balancers)
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'text/plain' })
    return res.end('OK')
  }

  // Small JSON endpoint
  if (req.url === '/api/info') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    return res.end(
      JSON.stringify({ name: NAME, port: Number(PORT), host: HOST, hits: ++hits, time: new Date().toISOString() }),
    )
  }

  hits++
  res.writeHead(200, { 'Content-Type': 'text/html' })
  res.end(`<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>${NAME} · ${PORT}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body{margin:0;font-family:system-ui,-apple-system,sans-serif;display:grid;place-items:center;
       min-height:100vh;background:${COLOR}10}
  .card{background:#fff;border:2px solid ${COLOR};border-radius:18px;padding:34px 46px;
        box-shadow:0 12px 34px #00000014;text-align:center}
  .dot{width:14px;height:14px;border-radius:50%;background:${COLOR};display:inline-block;margin-right:8px}
  h1{margin:.15em 0;color:${COLOR};font-size:40px}
  code{background:#f1f5f9;padding:2px 7px;border-radius:6px}
  .meta{color:#64748b;font-size:14px;margin-top:16px;line-height:1.9}
</style></head>
<body>
  <div class="card">
    <div style="font-size:18px"><span class="dot"></span><strong>${NAME}</strong></div>
    <h1>Port ${PORT}</h1>
    <div class="meta">
      host: <code>${HOST}</code><br>
      request #: <code>${hits}</code><br>
      ${new Date().toLocaleTimeString()}
    </div>
  </div>
</body></html>`)
})

server.listen(PORT, () => {
  console.log(`[${NAME}] listening on http://127.0.0.1:${PORT}`)
})
