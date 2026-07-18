const test = require('node:test')
const assert = require('node:assert')
const { priceWithTax } = require('../server.js')

test('adds tax and rounds to the nearest cent', () => {
  assert.strictEqual(priceWithTax(1000, 8), 1080)
  assert.strictEqual(priceWithTax(999, 0), 999)
})

test('rejects negative input', () => {
  assert.throws(() => priceWithTax(-1, 8))
})

// Break one of these on purpose (e.g. expect 1081) and push, to watch the
// pipeline go red on the pull request.
