# Week 7 — CI/CD & Infrastructure as Code

Five sessions. Three labs. One argument: **stop doing it by hand.**

```
week-7-cicd-iac/
├── github-actions/    S19 — 8 progressive workflows, hosted CI
├── jenkins/           S20 — 7 progressive Jenkinsfiles, self-hosted CI
└── terraform/         S21+S22 — 7 progressive labs, infrastructure as code
```

| Session | Lab | The idea |
|---|---|---|
| 18 — CI/CD Fundamentals | *(theory)* | Every pipeline is trigger → build → test → package → deploy |
| 19 — GitHub Actions | `github-actions/` | Someone else's machines, by the minute |
| 20 — Jenkins | `jenkins/` | Your machines, your responsibility |
| 21 — IaC concepts | *(theory)* | Why click-ops fails |
| 22 — Terraform | `terraform/` | The Week 6 environment, as text |

Each lab folder is numbered and **builds on itself** — start at `01` and add
one idea at a time. Each has its own README.

> The flow across the week: S19 and S20 automate how *code* reaches the
> servers. S21 and S22 turn the *servers themselves* into code. By Friday,
> nothing about your infrastructure exists only in someone's memory.

---

# GitHub Actions — from scratch

> **Want to just see it run first?** There is a ready-to-push project in
> [`github-actions/demo-app/`](github-actions/demo-app/) — a tiny app with a
> test, a Dockerfile, and a complete pipeline already at
> `.github/workflows/ci.yml`. Push it to a **new empty GitHub repo** and the
> Actions tab runs test → build → push-image live, no editing required. Its
> README walks the whole demo (including a pull request that goes red). Use it
> to show the payoff, then come back here to learn each piece from scratch.

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
| 08 | `08-full-pipeline.yml` | test → build image → push to registry → SSH pull & run. |
| 09 | `09-ssh-build-deploy.yml` | test on the runner → SSH to your server, which **builds and runs** the image itself. No registry. |

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

# Jenkins — the self-hosted half

Same concepts as GitHub Actions. Different words, and a lot more
responsibility: your server, your plugins, your disk, your backups.

```bash
cd jenkins
docker compose up -d --build
docker compose logs -f jenkins     # the setup password is in here
# open http://localhost:8080
```

Seven Jenkinsfiles in `jenkins/pipelines/`, 01 → 07, ending in a full pipeline
with a human approval gate. There is a tiny `app/` in there so the pipelines
build something real.

**→ Full instructions: [`jenkins/README.md`](jenkins/README.md)**

| Jenkins | GitHub Actions |
|---------|----------------|
| `pipeline { }` | the workflow file |
| `agent` | `runs-on` |
| `stage` | `job` |
| `credentials('id')` | `${{ secrets.NAME }}` |
| `when { branch 'main' }` | `if: github.ref == ...` |
| a plugin | an action |

The concepts transfer completely. What does not transfer is **who is
responsible when it breaks.**

⚠️ The lab mounts the host Docker socket into the Jenkins container. That is
effectively root on the host — fine on your laptop for an afternoon, never on
a server that matters.

---

# Terraform — infrastructure from code

Seven progressive labs: the smallest working config → the entire Week 6
environment as text → modules → remote state → a pipeline that plans on the
pull request and applies on merge.

```bash
cd terraform/01-first-bucket
terraform init
terraform plan       # SHOW me what you would do — read this, every time
terraform apply
terraform apply      # again. Nothing happens. That is idempotency.
terraform destroy    # ALWAYS
```

**→ Full instructions: [`terraform/README.md`](terraform/README.md)**

**Core (do these):**

| # | Teaches |
|---|---------|
| 01 | deploy an S3 bucket + the init/plan/apply/destroy loop |
| 02 | variables and outputs |
| 03 | deploy an EC2 instance (same pattern, now compute) |
| 07 | plan on the PR, apply on merge — Terraform in CI/CD |

**Optional / going further:**

| # | Teaches |
|---|---------|
| 04 | a full VPC + subnet + IGW + SG + EC2 + S3 |
| 05 | modules — one definition, separate state per environment |
| 06 | S3 remote backend with locking |

⚠️ **`terraform destroy` at the end of every sitting.** A forgotten EC2 is
~$8/month; a forgotten NAT gateway is ~$32/month. Terraform makes it trivially
easy to create forty things at once, and exactly as easy to forget you did.

⚠️ **`terraform.tfstate` holds every secret in plaintext** and is git-ignored
here on purpose. If it ever reaches a public repo, rotate everything in it —
deleting it in a later commit does nothing, the old commit still has it.

`.terraform.lock.hcl` **is** committed on purpose: it pins provider versions
for the team, exactly like `package-lock.json`.
