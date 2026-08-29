# 03 — deploy an EC2 instance

The same pattern as the bucket, aimed at compute. Provider + resource +
variables + outputs — a running server in one apply.

```bash
terraform init
terraform plan
terraform apply           # type: yes
terraform output public_ip
```

## What to notice

**Same shape, different resource.** The bucket was `aws_s3_bucket`; a server is
`aws_instance`. Everything else — provider, variables, outputs, the loop — is
identical. That is the whole point: learn the pattern once, use it for anything.

**Idempotency, again.** Run `terraform apply` a second time:
```
No changes. Your infrastructure matches the configuration.
```
Nothing is created, because the desired state already matches reality. This is
the same idempotency you saw with the bucket, on a completely different resource.

**The output gives you the IP** without opening the console:
```bash
terraform output -raw public_ip
```

## Clean up
```bash
terraform destroy
```

## Try this next
Read the [`aws_security_group`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
docs and add a security group to this config that allows port 22 (from your IP)
and port 80 (from anywhere), then attach it to the instance with
`vpc_security_group_ids`. That is exactly how you learn any new resource: read
the docs, fill in the arguments, plan, apply.

## Costs
t3.micro is free-tier eligible. A forgotten instance is ~$8/month — always
`terraform destroy` when you finish.
