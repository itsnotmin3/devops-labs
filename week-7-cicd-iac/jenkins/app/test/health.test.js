const test = require('node:test')
const assert = require('node:assert')

test('math still works', () => {
  assert.strictEqual(1 + 1, 2)
})

test('server module loads without listening', () => {
  const server = require('../server.js')
  assert.ok(server)
  assert.strictEqual(typeof server.listen, 'function')
})

// Break this one on purpose to watch the pipeline go red:
// test('this fails', () => { assert.strictEqual(1, 2) })
