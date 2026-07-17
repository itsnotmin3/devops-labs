# 03 — data sources & dependencies

A real server, provisioned from code, with nothing hard-coded that would
break in another region.

```bash
cp terraform.tfvars.example terraform.tfvars
curl ifconfig.me                       # your IP -> my_ip (KEEP the /32)

terraform init
terraform plan
terraform apply
curl $(terraform output -raw url)      # give it ~60s to install nginx
```

## What to notice

**The AMI is not written down anywhere.**
```bash
terraform output ami_used
```
`data "aws_ami"` looked up the current Ubuntu 24.04 in whatever region you
pointed at. Change `region` to `us-east-1`, re-plan, and it resolves a
*different* id automatically. A hard-coded `ami-0f5ee...` would simply not
exist there — that is the #1 reason a config works for its author and nobody
else.

**Nobody told Terraform the order.**
```bash
terraform graph | head -20
```
`vpc_security_group_ids = [aws_security_group.web.id]` is a *reference*, and
references are what build the dependency graph. The SG gets created first
because the instance mentions it — not because you said so.

> Hard-code `["sg-0abc123"]` there instead and you sever that edge. Then you
> need `depends_on` to glue it back. **If you are reaching for `depends_on`,
> the usual cause is a value you hard-coded where you should have referenced.**

**`most_recent = true` is not free.** Canonical publishes a new image, you run
`apply` for an unrelated reason, and the plan says `-/+ must be replaced`.
Immutable infrastructure (Session 21) says that is *fine* — but only if you
expected it. On production, pin the AMI in a variable and bump it deliberately.

**Try the validation:**
```bash
terraform apply -var="my_ip=1.2.3.4"    # no /32
```
Fails at plan time with your message. `can(cidrnetmask(...))` caught it before
AWS ever saw the request.

## Clean up
```bash
terraform destroy
```

## Costs
t3.micro is free-tier eligible for 750 h/month. **One instance left running
all month is ~$8 if you are past the free tier.** Destroy it.
