# 07 — Terraform in the pipeline

The payoff of the whole week.

A colleague opens a pull request that changes an instance type. The pipeline
runs `plan` and **posts the diff as a comment** — the reviewer reads
`1 to change, 0 to destroy` before approving anything. On merge, `apply` runs
from a clean machine using a role that expires in an hour.

Every one of Session 21's six click-ops problems is gone: reproducible,
reviewed, versioned, drift-checked, no tribal knowledge, no shared
credentials. **Sessions 18 through 22, in one file.**

## Setup

```bash
mkdir -p .github/workflows infra
cp terraform-plan-apply.yml .github/workflows/terraform.yml
cp ../04-full-environment/*.tf infra/
```

Then set up OIDC so GitHub can assume an AWS role without a stored key —
see *Rules that matter* below.

## Try it

1. Open a PR that changes `instance_type` from `t3.micro` to `t3.small`
2. Watch the plan appear as a comment: `~ 1 to change`
3. Merge → `apply` runs on main
4. Now open a PR that changes the **VPC CIDR** and read that plan carefully.
   It says `-/+ must be replaced` and it wants to destroy *everything*.
   **That is the review catching it.** That is the entire point.

## Rules that matter

| Rule | Why |
|---|---|
| `-auto-approve` only on `main` | The human gate is the PR review. Never on a PR branch. |
| `plan -out`, then apply the file | Apply exactly what was reviewed, not a fresh re-diff. |
| OIDC, not stored AWS keys | A leaked long-lived key is an incident. A 1-hour token is not. |
| `fmt -check` in CI | Ends style arguments mechanically. |
| One apply at a time | `concurrency:`. The state lock saves you; queueing is politer. |

## The gap this workflow still has

`plan -out=tfplan` writes a plan, and the **apply step re-plans from scratch**
rather than applying that file. Reality can move in between. The rigorous
version uploads `tfplan` as an artifact on the PR and applies *that exact file*
on merge — which is what Atlantis and Terraform Cloud do for you.

Worth knowing the gap exists rather than believing the YAML is airtight.

## Where this goes next

Add a **policy gate** — `tfsec`, `checkov`, or Open Policy Agent — that fails
the PR when the plan opens port 22 to `0.0.0.0/0` or creates an unencrypted
bucket:

```yaml
- name: Security scan
  run: |
    docker run --rm -v "$PWD:/src" aquasec/tfsec /src
```

Same shape as the test gate from Session 18, applied to infrastructure.
