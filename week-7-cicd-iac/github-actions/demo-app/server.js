// A tiny app for the GitHub Actions labs to build.
// Dependency-free on purpose: npm ci pulls nothing, so the pipeline runs fast
// and offline during a live class — no registry flakiness mid-demo.

const http = require('http')

const VERSION = process.env.APP_VERSION || 'dev'

// A pure function so the test has something real to check without a running server.
function priceWithTax(cents, ratePercent) {
  if (cents < 0 || ratePercent < 0) throw new Error('negatives not allowed')
  return Math.round(cents * (1 + ratePercent / 100))
}

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    return res.end(JSON.stringify({ status: 'ok', version: VERSION }))
  }
  res.writeHead(200, { 'Content-Type': 'text/html' })
  res.end(`<h1>ci-demo-app</h1><p>version: ${VERSION}</p>`)
})

// Only listen when run directly, so importing it in a test does not bind a port.
if (require.main === module) {
  const PORT = process.env.PORT || 3000
  server.listen(PORT, () => console.log(`listening on ${PORT}`))
}

module.exports = { server, priceWithTax }
