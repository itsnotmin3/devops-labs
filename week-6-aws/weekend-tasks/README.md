# Weekend AWS challenges

Seven tasks that put everything from the AWS week together — IAM, VPC + EC2, S3,
and Lambda + API Gateway. Do them in order; each builds on the last, and the
final two combine them into a small serverless app.

Work in the **AWS console and the CLI**. Where a task overlaps a lab in this
folder (`vpc-ec2/`, `lambda-api/`), use it — but understand each step, do not
just run the script.

## Ground rules

- **Free tier only:** t3.micro, small buckets, no NAT gateway.
- **Tag everything** `Project=weekend` so you can find it all in one filter.
- **Tear down after each sitting.** A forgotten instance bills by the second.
- **Set a budget first** (Task 0). Do not skip it.

---

## Task 0 — Safety net (5 min)

Before anything: **Billing → Budgets → Create budget** → monthly, **$5**, with a
**forecasted** alert to your email.

- [ ] Budget created and the confirmation email clicked.

---

## Task 1 — Lock down access (IAM)

1. Enable **MFA** on the root user and on your own IAM user.
2. Create an IAM user `developer` with a **custom policy** that allows only:
   read-only S3 (`s3:List*`, `s3:Get*`) and `ec2:Describe*` — nothing else.
3. Sign in as `developer` and try to **launch an EC2** (should be denied) and to
   **list S3 buckets** (should work).

- [ ] `developer` can list buckets but cannot launch an instance.
- [ ] You can explain *why* the launch was denied (default deny + no allow).

---

## Task 2 — A server from nothing (VPC + EC2)

Build the network by hand: a **VPC**, a **public subnet**, an **internet
gateway**, a **route table** with `0.0.0.0/0 → IGW`, and a **security group**
(80 from anywhere, 22 from your IP only). Launch a **t3.micro** with a
`user_data` script that installs NGINX and shows a message with your name.

> Stuck? Read `../vpc-ec2/up.sh` — it does exactly this, step by step.

- [ ] The instance's public IP serves your page.
- [ ] SSH works from your IP, and is refused from elsewhere.
- [ ] You can point at the route-table line that makes the subnet public.
- **Stretch:** launch a second instance in a *different* Availability Zone.

---

## Task 3 — Static site + a private file (S3)

1. Host a **static site** on S3 (index and error document both `index.html`).
2. Turn on **Block Public Access at the account level**, then make **only** the
   site bucket public with a bucket policy.
3. In a **second** bucket, upload a private file and generate a **presigned
   URL** with a 60-second expiry.

- [ ] The site loads in a browser.
- [ ] The private file opens via the presigned URL — and returns 403 after a minute.
- [ ] You can explain why Block Public Access did not break the website bucket.

---

## Task 4 — Roles, not keys (IAM + EC2 + S3)

Create an IAM **role** that grants read on **one** bucket, and attach it to the
EC2 instance from Task 2.

- [ ] `aws sts get-caller-identity` on the box shows an **assumed-role**.
- [ ] `aws s3 ls` on that one bucket works with **no keys configured**.
- [ ] Listing a *different* bucket is denied.

---

## Task 5 — Serverless API (Lambda + API Gateway)

Deploy the store API from `../lambda-api` (SAM or console). Then add a **fifth
route**: `GET /products/{id}/reviews` returning a stubbed list.

- [ ] All five routes respond correctly (test each with curl).
- [ ] You found the log line from one of your requests in **CloudWatch**.

---

## Task 6 — Integration: make the API read from S3

Right now `/products` returns a hard-coded list. Make it read from S3 instead.

1. Upload `starter/products.json` to a bucket.
2. Add `s3:GetObject` on that object to the Lambda's **execution role**, and set
   a `PRODUCTS_BUCKET` environment variable on the function.
3. Replace the `/products` handler with `starter/lambda_s3_products.py` (it reads
   the list from S3).

- [ ] Editing `products.json` in S3 changes the API response **with no redeploy**.
- [ ] If you remove the S3 permission, `/products` fails — and the CloudWatch log
      shows an AccessDenied. (Then put it back.)

---

## Task 7 — Tear it all down

- [ ] Terminate every instance; delete the VPC, subnet, gateway, route table, SGs.
- [ ] Delete the buckets, the Lambda/API, and the roles you created.
- [ ] The EC2 and S3 consoles are empty, and Billing shows nothing accruing.

> Leaving a NAT gateway, an Elastic IP, or an instance running is the number-one
> way a learner gets a surprise bill. This task matters as much as the others.

---

## Capstone (stretch) — a real serverless app

Wire a tiny **frontend on S3** that calls your **Lambda API**:

- A static `index.html` that `fetch()`es `/products` from your API and lists them.
- Enable **CORS** on the API so the browser is allowed to call it.

That is a complete serverless application — a static frontend on S3 and a JSON
API on Lambda, with no server anywhere. Everything you learned this week, in one
small system.
