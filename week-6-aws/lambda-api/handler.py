# Store API — one Lambda function serving four routes behind API Gateway.
# This is the exact handler from Session 18.
#
# API Gateway (HTTP API) hands the function an "event" dict. The two fields we use:
#   event["routeKey"]       -> the matched method + path, e.g. "GET /products/{id}"
#   event["pathParameters"] -> the { } parts of the path, e.g. {"id": "mug"}
#
# Whatever we return {"statusCode", "headers", "body"} becomes the HTTP response.

import json

PRODUCTS = [
    {"id": "book", "name": "Paperback", "price": 900},
    {"id": "mug", "name": "Coffee mug", "price": 1200},
    {"id": "sticker", "name": "Sticker pack", "price": 300},
]


def response(status, data):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(data),
    }


def lambda_handler(event, context):
    route = event.get("routeKey")
    params = event.get("pathParameters") or {}

    # Anything you print goes to CloudWatch Logs automatically.
    print(json.dumps({"msg": "request", "route": route}))

    if route == "GET /health":
        return response(200, {"status": "ok"})

    if route == "GET /products":
        return response(200, {"products": PRODUCTS})

    if route == "GET /products/{id}":
        product = next((p for p in PRODUCTS if p["id"] == params.get("id")), None)
        return response(200, product) if product else response(404, {"error": "not found"})

    if route == "POST /orders":
        try:
            body = json.loads(event.get("body") or "{}")
        except json.JSONDecodeError:
            return response(400, {"error": "body must be JSON"})
        items = body.get("items", [])
        if not isinstance(items, list):
            items = []
        return response(201, {"orderId": f"ord_{context.aws_request_id[:8]}", "items": items})

    return response(404, {"error": "no such route"})
