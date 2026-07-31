# Capstone API — the store API with the reviews route already included, so the
# frontend works with no code changes. Five routes, one Lambda.
#
# CORS (so a browser on another domain may call this) is turned on in the API
# Gateway console — not here. See the README.

import json

PRODUCTS = [
    {"id": "book", "name": "Paperback", "price": 900},
    {"id": "mug", "name": "Coffee mug", "price": 1200},
    {"id": "sticker", "name": "Sticker pack", "price": 300},
    {"id": "hoodie", "name": "Zip hoodie", "price": 4500},
]

REVIEWS = {
    "book": [
        {"user": "Asha", "stars": 5, "text": "Great read, finished it in a weekend."},
        {"user": "Rahul", "stars": 4, "text": "Good, a little slow in the middle."},
    ],
    "mug": [
        {"user": "Meera", "stars": 5, "text": "Keeps coffee hot for ages."},
    ],
    "sticker": [
        {"user": "Sam", "stars": 3, "text": "Nice, but smaller than I expected."},
    ],
    "hoodie": [
        {"user": "Ken", "stars": 5, "text": "Warm and the zip is solid."},
        {"user": "Priya", "stars": 4, "text": "Runs a size large."},
    ],
}


def response(status, data):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(data),
    }


def lambda_handler(event, context):
    route = event.get("routeKey")
    params = event.get("pathParameters") or {}

    if route == "GET /health":
        return response(200, {"status": "ok"})

    if route == "GET /products":
        return response(200, {"products": PRODUCTS})

    if route == "GET /products/{id}":
        product = next((p for p in PRODUCTS if p["id"] == params.get("id")), None)
        return response(200, product) if product else response(404, {"error": "not found"})

    if route == "GET /products/{id}/reviews":
        pid = params.get("id")
        return response(200, {"productId": pid, "reviews": REVIEWS.get(pid, [])})

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
