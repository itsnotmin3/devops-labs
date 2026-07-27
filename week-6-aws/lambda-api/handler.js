// Store API — one Lambda function serving four routes behind API Gateway.
// This is the exact handler from Session 18.
//
// API Gateway (HTTP API) hands the function an "event". The two fields we use:
//   event.routeKey       -> the matched method + path, e.g. "GET /products/{id}"
//   event.pathParameters -> the { } parts of the path, e.g. { id: "mug" }
//
// Whatever we return { statusCode, headers, body } becomes the HTTP response.

const PRODUCTS = [
  { id: 'book', name: 'Paperback', price: 900 },
  { id: 'mug', name: 'Coffee mug', price: 1200 },
  { id: 'sticker', name: 'Sticker pack', price: 300 },
]

const json = (statusCode, data) => ({
  statusCode,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(data),
})

exports.handler = async (event) => {
  const route = event.routeKey
  const params = event.pathParameters || {}

  // Everything the function logs goes to CloudWatch Logs automatically.
  console.log(JSON.stringify({ msg: 'request', route }))

  if (route === 'GET /health') {
    return json(200, { status: 'ok' })
  }

  if (route === 'GET /products') {
    return json(200, { products: PRODUCTS })
  }

  if (route === 'GET /products/{id}') {
    const product = PRODUCTS.find((p) => p.id === params.id)
    return product ? json(200, product) : json(404, { error: 'not found' })
  }

  if (route === 'POST /orders') {
    let body
    try {
      body = JSON.parse(event.body || '{}')
    } catch {
      return json(400, { error: 'body must be JSON' })
    }
    const items = Array.isArray(body.items) ? body.items : []
    return json(201, { orderId: 'ord_' + Date.now(), items })
  }

  return json(404, { error: 'no such route' })
}
