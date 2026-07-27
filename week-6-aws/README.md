# Week 6 — AWS

Hands-on AWS labs. Most of the AWS week is done in the console and CLI (IAM,
VPC, EC2, S3) following the sessions; this folder holds the one lab that is
worth having as code you can deploy and tear down.

```
week-6-aws/
└── lambda-api/     Session 18 — a four-route store API on Lambda + API Gateway
```

## lambda-api
A single Lambda function serving a small HTTP API (health, list products, get a
product, place an order), deployed behind API Gateway with AWS SAM. Deploy it
with one command, hit every endpoint with curl, read the logs in CloudWatch,
and delete it when you are done.

→ [`lambda-api/README.md`](lambda-api/README.md)

> The IAM, VPC/EC2 and S3 sessions are walked live in the AWS console and the
> AWS CLI — there is nothing to copy to a server for those, so they have no lab
> folder here. The serverless session is the one that benefits from being code.
