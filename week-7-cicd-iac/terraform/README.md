# Terraform — Session 23

Session 22 made the argument for Infrastructure as Code — declarative, desired
state, idempotency, drift. Here you type it.

Do the **core labs in order** — that is the whole session. The **optional** labs
go deeper and are there for when a real project needs them; you do not need them
to be productive.

```
terraform/
│  ── core (do these) ──
├── 01-first-bucket/        deploy an S3 bucket + the init/plan/apply/destroy loop
├── 02-variables-outputs/   variables and outputs
├── 03-deploy-ec2/          deploy an EC2 instance (same pattern, now compute)
├── 07-terraform-in-ci/     plan on the PR, apply on merge — the automated capstone
│
│  ── optional / going further ──
├── 04-full-environment/    a full VPC + subnet + gateway + SG + EC2 + S3
├── 05-modules/             package infrastructure into reusable modules
└── 06-remote-backend/      move state to a shared S3 backend with locking
```

The four core labs mirror the session step for step: deploy a bucket, add
variables and outputs, deploy a server, then wire Terraform into CI/CD.

---

## Before you start

```bash
terraform version           # 1.5+
aws sts get-caller-identity # if this fails, nothing below will work
```

Terraform reads the same credentials the AWS CLI uses. **Never put
`access_key` in a provider block** — it ends up in git, and a leaked AWS key
is mined for crypto within minutes. The bots watch GitHub's public event
stream.

---

## The loop you will run ten thousand times

```bash
terraform init      # download providers (once per project)
terraform fmt       # canonical style (before every commit)
terraform validate  # syntax — no credentials needed, fast
terraform plan      # SHOW me what you would do    <- the whole product
terraform apply     # do it
terraform destroy   # remove it
```

## Reading a plan — the five symbols

| Symbol | Means | Read it as |
|---|---|---|
| `+` | create | A new thing. Usually fine. |
| `~` | update in place | Changed, no downtime. Usually fine. |
| `-` | destroy | It goes away. Look hard. |
| `-/+` | **destroy and re-create** | **New ID, new IP, data gone. Look very hard.** |
| `<=` | read (data source) | Just a lookup. Harmless. |

`-/+` is where outages come from. Some arguments cannot be changed on a live
resource — an EC2 subnet, an RDS name, a bucket name — so Terraform deletes
and rebuilds. On a database, that is your data.

The plan tells you honestly, in advance, and names the offending argument with
`# forces replacement`. **The only failure mode is not reading it.**

---

## ⚠️ Money

Everything here is free-tier if you follow it exactly: `t3.micro`, one small
bucket, **no NAT gateway**.

The rule is simple and unforgiving: **`terraform destroy` at the end of every
sitting.**

| Forgotten | Costs |
|---|---|
| An EC2 instance | ~$8/month |
| A NAT gateway | ~$32/month |
| An ALB | ~$16/month |
| An unattached Elastic IP | billed *because* it is unused |

Terraform makes it trivially easy to create forty things at once, and exactly
as easy to forget you did.

---

## ⚠️ State is a secret

`terraform.tfstate` holds **every attribute AWS returned, in plaintext** —
including RDS passwords and generated keys. It is not encrypted on disk.

- `.gitignore` it **before** your first apply, not after the first accident
- Never in a public repo. If it lands in one, **rotate everything in it** —
  deleting the file in a new commit does nothing, the old commit still has it
- The moment a second person is involved, it belongs in an encrypted remote
  backend (lab 06)

`.terraform.lock.hcl` **is** committed, on purpose — it pins provider versions
for the whole team. Same idea as `package-lock.json`.

---

## Terraform ⇄ things you already know

| Terraform | You have seen this before |
|---|---|
| desired state, reconciliation | Docker Compose (Week 5) — one file, one command |
| idempotency | `docker compose up` twice changes nothing |
| a plan before a change | reading a `git diff` before you commit |
| state | Compose's "which containers belong to this project" |
| modules | functions |
| `plan` on the PR | the test gate from Session 18 |

Your Compose file is infrastructure as code for a single host. Terraform is
the same idea pointed at a cloud account. Kubernetes manifests (Week 8) will
be the same idea again, pointed at a cluster.

**Three tools, one concept.**

---

## A note on the licence, since someone always asks

In 2023 HashiCorp changed Terraform from open source (MPL) to the Business
Source Licence. The community forked the last MPL version as **OpenTofu**, now
under the Linux Foundation.

OpenTofu is a drop-in replacement — same HCL, same commands, swap the binary.
Everything in these labs works identically on both.

Learn Terraform; you have also learned OpenTofu.
