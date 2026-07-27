# Week 6 — AWS

Hands-on AWS labs. Most of the AWS week is done in the console and CLI (IAM,
VPC, EC2, S3) following the sessions; this folder holds the one lab that is
worth having as code you can deploy and tear down.

```
week-6-aws/
├── vpc-ec2/        Session 16 — scripted VPC + subnet + gateway + EC2, and teardown
└── lambda-api/     Session 18 — a four-route store API on Lambda + API Gateway
```

## vpc-ec2
Two shell scripts that build the whole Session 16 network — VPC, public subnet,
internet gateway, route table, security group — and launch an EC2 instance
running NGINX inside it, then tear it all down. Watch each piece get created in
order, open the URL, and clean up with one command.

→ [`vpc-ec2/README.md`](vpc-ec2/README.md)

## lambda-api
A single Lambda function serving a small HTTP API (health, list products, get a
product, place an order), deployed behind API Gateway with AWS SAM. Deploy it
with one command, hit every endpoint with curl, read the logs in CloudWatch,
and delete it when you are done.

→ [`lambda-api/README.md`](lambda-api/README.md)

> The IAM and S3 sessions are walked live in the AWS console and the CLI —
> there is nothing to copy to a server for those, so they have no lab folder
> here. VPC/EC2 and serverless are the ones that benefit from being scripted.
