# 05 — modules

Lab 04 built one environment. The moment you need a second, you face the same
choice as any programmer with a useful function: **copy it, or factor it.**

```
modules/web_server/     the module — resources, inputs, outputs
envs/staging/           calls it with small values
envs/prod/              calls it with big values
```

```bash
cd envs/staging
terraform init          # note: it also loads the local module
terraform apply
terraform output

cd ../prod
terraform init
terraform apply

# Two complete environments. One definition. Both destroy separately:
terraform destroy       # in prod/
cd ../staging && terraform destroy
```

## The thing that makes this work

**Each env directory has its OWN state file.** That is why this is real
isolation, and why lab 02's two-tfvars trick was not: there, both applies
shared one state, so the second replaced the first. Here, `envs/staging` and
`envs/prod` cannot touch each other. A mistake in staging *cannot* reach prod,
because they do not share a file.

Split state by environment first, then by blast radius (network / data / app).
One monolithic state for a whole company means every plan takes ten minutes
and every apply is terrifying.

## What to notice

**The module has no `provider` block.** It inherits one from its caller. This
is deliberate — a provider inside a reusable module makes it impossible to
call twice with different regions, and Terraform will warn you about it.

**`module.web.web_url`** is how a caller reads a module output. The module's
`variables.tf` is its function signature; `outputs.tf` is its return value.

**The CIDRs must not overlap.** 10.1.0.0/16 and 10.2.0.0/16. If you ever want
these VPCs to peer, overlapping ranges make it impossible — and you find out
years later.

## Do NOT build a module on day one

The instinct after learning modules is to abstract everything immediately.
**Resist it.**

A module written before you have two real callers is a *guess* about what
varies, and it will be wrong. You end up with fifteen variables that exist to
paper over a bad abstraction.

Write it concrete (lab 04). Copy it once. Factor out **what actually
differed**. Same rule as any other code.

## Use the registry before writing your own

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  # ...
}
```

`terraform-aws-modules/vpc/aws` has been used by hundreds of thousands of
projects and handles the NAT gateways, flow logs and multi-AZ arrangements you
have not thought about yet. Writing a VPC module from scratch is a good
learning exercise and a bad production decision.

## `source` values you will meet

| `source =` | Means |
|---|---|
| `"../../modules/web_server"` | A local path. Start here. |
| `"terraform-aws-modules/vpc/aws"` | The public registry. |
| `"git::https://github.com/org/mods.git//vpc?ref=v1.4.0"` | A git repo, **pinned to a tag**. How most companies do it. |

Always pin the ref. An unpinned module is someone else's `main` branch
deploying to your production.
