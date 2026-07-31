# Lambda + API Gateway — a four-route API, live

Session 18, hands-on. One Lambda function serves a small store API — health,
list products, get one product, place an order — behind an HTTP API Gateway.

```
lambda-api/
├── handler.py      the function (four routes, one handler)
├── template.yaml   AWS SAM — defines the function, the API, and the routes
└── requirements.txt  Python deps (none — it uses only the standard library)
```

---

## Option A — deploy with SAM (recommended, reproducible)

SAM is AWS's Infrastructure-as-Code for serverless: `template.yaml` IS the
setup, and one command builds all of it — function, API, routes, and the IAM
execution role.

**Prerequisites**
- AWS CLI configured (`aws sts get-caller-identity` works)
- SAM CLI installed — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html

**Deploy**
```bash
cd week-6-aws/lambda-api
sam build
sam deploy --guided        # first time: accept the defaults, say "yes" to deploy
```
At the end SAM prints an **`ApiUrl`** output — copy it. (Later deploys are just
`sam deploy`.)

**Test every route** (replace `$API` with the ApiUrl):
```bash
API="https://xxxx.execute-api.ap-south-1.amazonaws.com"

curl -s $API/health
# {"status":"ok"}

curl -s $API/products
# {"products":[{"id":"book",...},{"id":"mug",...},{"id":"sticker",...}]}

curl -s $API/products/mug
# {"id":"mug","name":"Coffee mug","price":1200}

curl -s $API/products/nope
# {"error":"not found"}         (a 404)

curl -s -X POST $API/orders -H 'Content-Type: application/json' -d '{"items":["mug","book"]}'
# {"orderId":"ord_1721...","items":["mug","book"]}
```

**See the logs** (they go to CloudWatch automatically):
```bash
sam logs --stack-name <the-name-you-gave-it> --tail
```

**Tear it down** when you are done:
```bash
sam delete
```

---

## Option B — the console (no tools, good for a first look)

1. **Lambda → Create function** → Author from scratch → runtime **Python 3.12** →
   Create.
2. Paste the contents of `handler.py` into the code editor → **Deploy**.
3. **Add trigger → API Gateway → Create an HTTP API** → open (or leave it and add
   routes next).
4. In **API Gateway → your API → Routes**, add the four routes, each pointing at
   the function:
   - `GET /health`
   - `GET /products`
   - `GET /products/{id}`
   - `POST /orders`
5. Copy the API's **Invoke URL** and run the same curl commands as above.
6. **Monitor → View CloudWatch logs** to see each request.

> The console is quicker to see once; SAM is how you would actually keep it,
> review it, and recreate it — the Infrastructure-as-Code lesson from Week 7,
> applied to serverless.

---

## Things worth pointing out during the demo

- **No server.** There is no `app.listen()`, no port, no box to SSH into. AWS
  runs the function only when a request arrives.
- **One function, four routes.** The handler branches on `event.routeKey` — the
  method-and-path API Gateway matched. Look at the logs and you will see the
  route on every request.
- **The execution role.** SAM created an IAM role for the function
  automatically. To let it read an S3 bucket, you add a policy to that role in
  `template.yaml` — never an access key. (That is the homework.)
- **Cost.** This sits inside the free tier. Idle, it costs nothing — there is
  nothing running.

## Break it on purpose

Add `raise Exception("boom")` at the top of the `GET /products` branch,
redeploy (`sam build && sam deploy`), hit `/products`, and watch it return a
502 — then open the logs with `sam logs --tail` and find the traceback. That is
the whole debugging loop for a Lambda: the logs are where the "why" lives.
