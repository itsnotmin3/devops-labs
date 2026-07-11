// A stand-in for a real build tool (Vite/webpack). Zero dependencies.
// Reads src/index.html, injects a build timestamp, writes dist/index.html.
const fs = require('fs')
const path = require('path')

fs.mkdirSync('dist', { recursive: true })
const src = fs.readFileSync(path.join('src', 'index.html'), 'utf8')
const out = src.replace('{{BUILD_TIME}}', new Date().toISOString())
fs.writeFileSync(path.join('dist', 'index.html'), out)

console.log('✓ built dist/index.html')
