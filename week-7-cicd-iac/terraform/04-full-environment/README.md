# 04 — the whole Week 6 environment, as code

Everything you clicked together in Week 6 — VPC, subnet, internet gateway,
route table, security group, EC2 running nginx, S3 bucket — as text.

```bash
cp terraform.tfvars.example terraform.tfvars   # set your own `suffix`

terraform init
terraform apply -var="environment=dev"

curl $(terraform output -raw web_url)          # ~60s for nginx to install
terraform destroy -var="environment=dev"       # DO THIS
```

11 resources. Correct order. Parallel where possible. **About 90 seconds.**

## Sit with what just happened

Week 6 took most of a session to click that together and produced nothing
anyone could reuse. This produces the same environment in 90 seconds, from a
file that:

- is in git, so it has a history and a blame
- a colleague can review in a pull request
- rebuilds *identically* in Frankfurt tomorrow
- tears down completely, leaving nothing to forget about

Every problem on Session 21's click-ops list is now **solved**, not argued
about.

## What to notice

**What makes a subnet public?** Nothing about the subnet. There is no
`public = true`. It is public because its route table has a `0.0.0.0/0` route
to an internet gateway. Delete that route and the identical subnet is private.
The console hides this; `network.tf` cannot.

**`cidrsubnet(var.vpc_cidr, 8, 1)`** — the Week 3 CIDR maths, automated. Take a
/16, add 8 bits → a /24, give me #1 → `10.0.1.0/24`. Check it:
```bash
terraform console
> cidrsubnet("10.0.0.0/16", 8, 1)
```

**The teardown order.** Run `destroy` and watch: instance → subnet → VPC. The
exact reverse of creation, worked out from the same graph. You never wrote an
order down, in either direction.

**The bucket takes four resources.** In AWS provider v4+, versioning,
encryption and public-access-block were split out of `aws_s3_bucket`. Every
pre-2022 tutorial shows them inline and will not work. This is a provider
major bump from the inside — and why `~> 5.0` beats `>= 4.0`.

**The SSH rule does not exist unless you ask for it.** The `dynamic "ingress"`
block is skipped when `allowed_ssh_cidr` is empty. The safe path is the
default path, not the disciplined one.

## Try this

```bash
# 1. Change the region and re-plan. The AMI resolves to a different id.
terraform plan -var="environment=dev" -var="region=us-east-1"

# 2. Deliberately create DRIFT: change the instance type in the AWS console,
#    then ask Terraform what it thinks.
terraform plan -var="environment=dev"
#    It wants to change it BACK. That is reconciliation (Session 21).
#    Terraform is not confused — it is doing its job.

# 3. Break something on purpose:
terraform state list
terraform state rm aws_s3_bucket.assets    # forget it WITHOUT deleting it
terraform plan -var="environment=dev"      # now it wants to CREATE it again
#    ...and the create will fail: the real bucket still exists.
#    Fix it by adopting the real one back:
terraform import -var="environment=dev" aws_s3_bucket.assets bootcamp-dev-assets-4471
```

That last one is the migration path out of click-ops: `terraform import`
adopts infrastructure that already exists, without destroying it.

## Costs

Free-tier if you follow it exactly: t3.micro, one small bucket, **no NAT
gateway**. `terraform destroy` at the end of every sitting — an EC2 you forget
is ~$8/month, a NAT gateway you forget is ~$32/month.

Terraform makes it trivially easy to create 11 things at once, and exactly as
easy to forget you did.
