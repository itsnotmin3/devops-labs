# Week 7 — CI/CD & Infrastructure as Code

```
week-7-cicd-iac/
├── github-actions/    8 progressive workflows — start at 01, build up to a real pipeline
└── terraform/         provision an EC2 + security group + nginx from code
```

---

# GitHub Actions — from scratch

Eight workflows that build on each other. **Copy one at a time** into your own app
repo at `.github/workflows/` and watch it run in the **Actions** tab.

> They live in `github-actions/` (not `.github/workflows/`) on purpose — so they
> do not execute on this labs repo. Copy the one you are learning:
> ```bash
> mkdir -p .github/workflows
> cp github-actions/01-hello.yml .github/workflows/
> git add . && git commit -m "ci: hello" && git push
> ```

| # | File | What it teaches |
|---|------|-----------------|
| 01 | `01-hello.yml` | The smallest workflow: one event, one job, one step |
| 02 | `02-triggers.yml` | `on:` — push, pull_request, manual, schedule (cron) |
| 03 | `03-node-ci.yml` | A real CI: checkout → setup-node → `npm ci` → test → build |
| 04 | `04-jobs-needs.yml` | Multiple jobs run in parallel; `needs:` creates order + gates |
| 05 | `05-matrix.yml` | One job, many versions — test on Node 18/20/22 at once |
| 06 | `06-secrets-env.yml` | `env:` for config, `secrets:` for credentials |
| 07 | `07-docker-build-push.yml` | Build your Week 4 image, push to ghcr.io |
| 08 | `08-full-pipeline.yml` | test → build → deploy over SSH. The real thing. |

## The mental model
```
Event (push)  ─►  Workflow (a .yml file)
                    └── Job  (runs on a fresh runner VM)
                          └── Step  (a shell command, or a reusable "action")
```
- **Workflow** = the file. **Event** = when it runs. **Job** = a machine.
  **Step** = one thing to do. **Action** = a step someone already wrote (`actions/checkout`).
- Jobs are **parallel** by default; `needs:` makes them sequential.
- Every job starts on an **empty** runner — that is why step 1 is always `checkout`.

## Try it in order
```bash
# 01 — see it run at all (Actions tab -> Run workflow)
# 02 — push to main and watch it fire; note github.event_name
# 03 — the real CI; break a test on a branch, open a PR, watch it go red
# 04 — see lint+test run side by side, deploy wait for both
# 05 — one job, three Node versions, all in parallel
# 06 — add a secret named MY_SECRET, re-run, see it detected (not printed)
# 07 — needs a Dockerfile in the repo; check Packages after it runs
# 08 — add SSH_HOST / SSH_USER / SSH_KEY secrets, push to main, app is live
```

## Secrets you will need (07/08)
| Secret | Value |
|--------|-------|
| `GITHUB_TOKEN` | provided automatically — do not create it |
| `SSH_HOST` | your server's IP |
| `SSH_USER` | `ubuntu` |
| `SSH_KEY` | the **contents** of your private `.pem` |

⚠️ Never commit a key or token. Secrets live in **Settings → Secrets and variables → Actions**.

---

# Terraform — infrastructure from code

Provisions an EC2 instance + security group and installs nginx on first boot.

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # fill in key_name and my_ip
curl ifconfig.me                                # your IP for my_ip (add /32)

terraform init      # download the AWS provider
terraform plan      # SHOW me what you would change (read this every time)
terraform apply     # do it — outputs the public IP + ssh command
# open the url output in a browser

terraform destroy   # tear it all down (do this after class!)
```

Needs AWS credentials: `aws configure` (or exported env vars).

⚠️ `terraform.tfstate` is **git-ignored** — it can contain secrets and is
environment-specific. In a team you keep it in remote state (an S3 bucket).
