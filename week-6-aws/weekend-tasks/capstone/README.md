# Capstone — a serverless app: S3 frontend + Lambda API

A complete little app with no server anywhere: a static page on **S3** that
calls a **Lambda API** through **API Gateway**. Everything from the AWS week in
one system — built by hand in the console.

```
capstone/
├── handler.py    the API — five routes INCLUDING /products/{id}/reviews
└── index.html    the frontend — lists products and shows reviews on click
```

The reviews route is already in `handler.py`, so there is **no code to edit** —
you just paste the code once and paste one URL into the page.

---

## Step 1 — create the Lambda (console)

1. **Lambda → Create function** → Author from scratch.
2. Name it `store-api`, runtime **Python 3.12** → Create.
3. In the code editor, replace the contents of `lambda_function.py` with the
   whole of **`handler.py`** from this folder.
4. The default **Handler** is `lambda_function.lambda_handler`, and our function
   is named `lambda_handler`, so it already matches. **Deploy**.
5. Quick check: **Test** → paste `{ "routeKey": "GET /products" }` → Run. You
   should see the product list come back.

## Step 2 — put an HTTP API in front of it

1. On the function page: **Add trigger → API Gateway → Create an HTTP API** →
   Security: **Open** → Add.
2. Go to **API Gateway → your API → Routes** and add these five routes, each
   with **Integration = your Lambda**:
   - `GET /health`
   - `GET /products`
   - `GET /products/{id}`
   - `GET /products/{id}/reviews`
   - `POST /orders`
3. Copy the API's **Invoke URL** (looks like
   `https://abc123.execute-api.ap-south-1.amazonaws.com`).

Test it from your terminal:
```bash
API="https://abc123.execute-api.ap-south-1.amazonaws.com"
curl -s $API/products
curl -s $API/products/hoodie/reviews
```

## Step 3 — turn on CORS (so a browser may call it)

A page served from S3 is a different origin from the API, so the browser will
block the call until you allow it.

1. **API Gateway → your API → CORS → Configure**.
2. Set:
   - **Access-Control-Allow-Origin:** `*`
   - **Access-Control-Allow-Methods:** `GET, POST, OPTIONS`
   - **Access-Control-Allow-Headers:** `*`
3. Save.

## Step 4 — point the frontend at your API

Open `index.html` and paste your Invoke URL into the one line at the top:

```js
const API = "https://abc123.execute-api.ap-south-1.amazonaws.com";
```

You can double-click `index.html` to test it locally first — with CORS on, it
will work even from a file.

## Step 5 — host the frontend on S3

1. **S3 → Create bucket** — a globally unique name like `capstone-frontend-4471`.
2. **Properties → Static website hosting → Enable**, index document `index.html`.
3. **Permissions:** turn **off** Block Public Access *for this bucket*, then add
   a bucket policy allowing public `s3:GetObject`:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Principal": "*",
       "Action": "s3:GetObject",
       "Resource": "arn:aws:s3:::capstone-frontend-4471/*"
     }]
   }
   ```
4. **Upload** `index.html` to the bucket.
5. Open the **website endpoint** (Properties → Static website hosting):
   `http://capstone-frontend-4471.s3-website-<region>.amazonaws.com`

You should see the products load, and clicking **Show reviews** on any product
fetches its reviews from the API — live.

## Step 6 — tear it down

- Delete the S3 bucket (empty it first).
- Delete the API in API Gateway.
- Delete the Lambda function.
- Delete the execution role it created (IAM → Roles) if you want it fully clean.

---

## What you just built

- **Frontend:** static HTML/JS on S3 — no web server, scales for free.
- **API:** a Lambda behind API Gateway — runs only on request, costs nothing idle.
- **The link:** the browser calls the API directly; CORS is what makes the
  browser allow it.

No EC2, no container, no server to patch — and it would serve thousands of users
without you changing a thing. That is the whole AWS week working together.

## Take it further

- Make `/products` read from S3 (the Task 6 starter) so you can edit the catalog
  without touching the function.
- Add a **Buy** button that POSTs to `/orders` and shows the returned order id.
- Put **CloudFront** in front of the S3 site for HTTPS and a custom domain.
