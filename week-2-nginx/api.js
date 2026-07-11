// A second tiny service — ZERO dependencies.
// Run with:  node api.js   (PORT default 4000)
// Use it for the "reverse proxy by path" demo: NGINX  location /api/  ->  this.

const http = require('http')

const PORT = process.env.PORT || 4000
const users = [
  { id: 1, name: 'Asif' },
  { id: 2, name: 'Sara' },
  { id: 3, name: 'Bilal' },
]

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'text/plain' })
    return res.end('OK')
  }

  res.setHeader('Content-Type', 'application/json')

  if (req.url === '/api/time' || req.url === '/time') {
    return res.end(JSON.stringify({ service: 'api', time: new Date().toISOString() }))
  }
  if (req.url === '/api/users' || req.url === '/users') {
    return res.end(JSON.stringify({ service: 'api', users }))
  }

  res.end(
    JSON.stringify({ service: 'api', message: 'Hello from the API service', endpoints: ['/api/time', '/api/users'] }),
  )
})

server.listen(PORT, () => console.log(`[api] listening on http://127.0.0.1:${PORT}`))
