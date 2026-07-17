// Deliberately dependency-free: no npm install needed, so the labs work
// on a slow connection and never fail for reasons that are not the lesson.
const http = require('http')

const PORT = process.env.PORT || 3000
const VERSION = process.env.APP_VERSION || 'dev'

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    return res.end(JSON.stringify({ status: 'ok', version: VERSION }))
  }
  res.writeHead(200, { 'Content-Type': 'text/html' })
  res.end(`<h1>store-api</h1><p>version: ${VERSION}</p>`)
})

// Only listen when run directly, so the tests can import it without
// binding a port and hanging the test runner.
if (require.main === module) {
  server.listen(PORT, () => console.log(`listening on ${PORT}`))
}

module.exports = server
